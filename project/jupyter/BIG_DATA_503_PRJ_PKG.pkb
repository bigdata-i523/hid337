create or replace PACKAGE BODY BIG_DATA_503_PRJ_PKG AS
  /*
     Description:
         This pl/sql Package contains needed procedures for generation of 
         Test/Training Data needed for the final project of i523 Big Data Analytics Course
      
     Date           Author           Comments
     12/01/2017     HID337,HID333    Initial version
  
  */
  --Global constants
  --FEATURES
  G_FEATURE_INT_AMB_TEMP  VARCHAR2(60):='INT_AMB_TEMP';
  G_FEATURE_EXT_AMB_TEMP  VARCHAR2(60):='EXT_AMB_TEMP';
  G_FEATURE_INPUT_CUR     VARCHAR2(60):='INTPUT_CUR';
  G_FEATURE_INPUT_VOLT    VARCHAR2(60):='INTPUT_VOLT';
  G_FEATURE_X_AXIS        VARCHAR2(60):='VIB_X_AXIS';
  G_FEATURE_Y_AXIS        VARCHAR2(60):='VIB_Y_AXIS';
  G_FEATURE_Z_AXIS        VARCHAR2(60):='VIB_Z_AXIS';
  
  -- EQUIPMENT/PART NUMBERS
  G_EQP1_NAME             VARCHAR2(60):='Vacuum Blower';
  G_EQP1_PART_NAME        VARCHAR2(60):='38000-010';
  G_EQP2_NAME             VARCHAR2(60):='Smart Valve';
  G_EQP2_PART_NAME        VARCHAR2(60):='38000-020';
  G_EQP3_NAME             VARCHAR2(60):='Air Compressor';
  G_EQP3_PART_NAME        VARCHAR2(60):='38000-030';
  
  --LABELS
  G_LABEL_NORMAL          VARCHAR2(60):='NORMAL_OP_30_DEG_C';
  G_LABEL_OVER_CURR       VARCHAR2(60):='OVER_CURRENT_FAULT_OP';
  G_LABEL_OVER_TEMP       VARCHAR2(60):='OVER_TEMP_FAULT_OP';
  G_LABEL_OVER_VOLT       VARCHAR2(60):='INPUT_OVER_VOLT_FAULT_OP';
  G_LABEL_AB_OP30_DEG     VARCHAR2(60):='ABNORMAL_OP_30_DEG_C';
  G_LABEL_BERING_DEG_OP   VARCHAR2(60):='BEARING_DEGRADE_OP';
  
  --EQP1 SERIALS
  G_EQP1_SERIAL1                   VARCHAR2(60):='P1-SN01';
  G_EQP1_SERIAL2                   VARCHAR2(60):='P1-SN02';
  G_EQP1_SERIAL3                   VARCHAR2(60):='P1-SN03';
  G_EQP1_SERIAL4                   VARCHAR2(60):='P1-SN04';
  G_EQP1_SERIAL5                   VARCHAR2(60):='P1-SN05';
  G_EQP1_SERIAL6                   VARCHAR2(60):='P1-SN06';
  G_EQP1_SERIAL7                   VARCHAR2(60):='P1-SN07';
  G_EQP1_SERIAL8                   VARCHAR2(60):='P1-SN08';
  G_EQP1_SERIAL9                   VARCHAR2(60):='P1-SN09';
  G_EQP1_SERIAL10                  VARCHAR2(60):='P1-SN010';
  G_EQP1_SERIAL11                  VARCHAR2(60):='P1-SN011';
  G_EQP1_SERIAL12                  VARCHAR2(60):='P1-SN012';
  G_EQP1_SERIAL13                  VARCHAR2(60):='P1-SN013';
  G_EQP1_SERIAL14                  VARCHAR2(60):='P1-SN014';
  G_EQP1_SERIAL15                  VARCHAR2(60):='P1-SN015';

  --EQP2 SERIALS
  G_EQP2_SERIAL1                   VARCHAR2(60):='P2-SN01';
  G_EQP2_SERIAL2                   VARCHAR2(60):='P2-SN02';
  G_EQP2_SERIAL3                   VARCHAR2(60):='P2-SN03';
  --EQP3 SERIALS
  G_EQP3_SERIAL1                   VARCHAR2(60):='P3-SN01';
  G_EQP3_SERIAL2                   VARCHAR2(60):='P3-SN02';
  G_EQP3_SERIAL3                   VARCHAR2(60):='P3-SN03';
  
  --NORMAL PARAM DEFAULTS
  G_NRM_INT_TEMP    NUMBER:=40;
  G_NRM_EXT_TEMP    NUMBER:=30;
  G_NRM_CUR             NUMBER:=12;
  G_NRM_VOLT            NUMBER:=115;
  --ABNORMAL PARAM DEFAULTS
  G_OVER_CUR             NUMBER:=20;
  G_OVER_INT_TEMP        NUMBER:=90;
  G_OVER_VOLT            NUMBER:=135;
  G_OVER_EXT_TEMP        NUMBER:=45;
  G_DEGRADE_INT_TEMP     NUMBER:=90;
  G_DEGRADE_EXT_TEMP     NUMBER:=50;
  G_DEGRADE_CUR          NUMBER:=18;
  G_DEGRADE_VOLT         NUMBER:=120;
   
  --MATH VARIABLES
  G_STEP_SIZE                 NUMBER:=.5;
  G_LOW_TOLERANCE             NUMBER:=.9; -- -ve  10%
  G_HIGH_TOLERANCE            NUMBER:=1.1;-- -+ve 10%
  
  --Procedure to update Test Data with Classified Labels. This gets called from python code.
  PROCEDURE update_testdata_labels(p_id_list IN NUM_ARRAY,p_result_list string_array) IS
  BEGIN
   
    FOR i IN 1..p_id_list.COUNT 
    LOOP
       update SENSOR_TEST_DATA
       set label = p_result_list(i)
       where record_id = p_id_list(i);
    END LOOP ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END update_testdata_labels; 
  
  --Procedure to insert tabel SENSOR_TRAIN_DATA with Training Set data.
  PROCEDURE insert_train_set_recs(p_eqp_name VARCHAR2,p_part_name VARCHAR2,p_label VARCHAR2,p_int_amb_temp NUMBER,
                                  p_ext_amb_temp NUMBER,p_input_cur NUMBER,p_input_volt NUMBER,
                                  p_x_axis NUMBER,p_y_axis NUMBER,p_z_axis NUMBER,p_param_to_update VARCHAR2) IS
                                  
  l_eqp_name      varchar2(60);
  l_part_name     varchar2(60);
  l_label         varchar2(60);
  l_int_amb_temp  number; 
  l_ext_amb_temp  number;
  l_input_cur     number; 
  l_input_volt    number; 
  l_vib_x_axis    number; 
  l_vib_y_axis    number;
  l_vib_z_axis    number;
  l_low_val       number;
  l_high_val      number;
  l_variable_val  number;
  
  BEGIN
    l_eqp_name:=p_eqp_name;
    l_part_name:=p_part_name;
    l_label:=p_label;
    l_int_amb_temp:=p_int_amb_temp;
    l_ext_amb_temp:=p_ext_amb_temp;
    l_input_cur:=p_input_cur;
    l_input_volt:=p_input_volt;
    l_vib_x_axis:=p_x_axis;
    l_vib_y_axis:=p_y_axis;
    l_vib_z_axis:=p_z_axis;
                          
    if(G_FEATURE_INT_AMB_TEMP = p_param_to_update)then
      l_low_val:= l_int_amb_temp*G_LOW_TOLERANCE;
      l_high_val:= l_int_amb_temp*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_variable_val,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_EXT_AMB_TEMP = p_param_to_update)then
      l_low_val:= l_ext_amb_temp*G_LOW_TOLERANCE;
      l_high_val:= l_ext_amb_temp*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_variable_val,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_INPUT_CUR = p_param_to_update)then
      l_low_val:= l_input_cur*G_LOW_TOLERANCE;
      l_high_val:= l_input_cur*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_variable_val,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_INPUT_VOLT = p_param_to_update)then
      l_low_val:= l_input_volt*G_LOW_TOLERANCE;
      l_high_val:= l_input_volt*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_variable_val,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_X_AXIS = p_param_to_update)then
      l_low_val:= l_vib_x_axis*G_LOW_TOLERANCE;
      l_high_val:= l_vib_x_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_variable_val,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_Y_AXIS = p_param_to_update)then
      l_low_val:= l_vib_y_axis*G_LOW_TOLERANCE;
      l_high_val:=l_vib_y_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val > l_high_val) -- y axis is -ve
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_variable_val,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+(-1*G_STEP_SIZE);
      end loop;
    elsif(G_FEATURE_Z_AXIS = p_param_to_update)then
      l_low_val:= l_vib_z_axis*G_LOW_TOLERANCE;
      l_high_val:=l_vib_z_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val > l_high_val) -- z axis is -ve
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_variable_val,l_label,sysdate);
        l_variable_val:=l_variable_val+(-1*G_STEP_SIZE);
      end loop;
    end if;
  
  END insert_train_set_recs;
  
  --Procedure to generate training set data. 
  --Parameter: P_EQP_NAME: This parameter decides for which equipment to generate data
  PROCEDURE generate_eqp_train_set(P_EQP_NAME   VARCHAR2) IS
    l_x_axis               NUMBER;
    l_Y_axis               NUMBER;
    l_Z_axis               NUMBER;
    l_degrade_x_axis       NUMBER;
    l_degrade_Y_axis       NUMBER;
    l_degrade_Z_axis       NUMBER;
    l_part_name            VARCHAR2(60);
  
  BEGIN
  
    IF(P_EQP_NAME = G_EQP1_NAME)THEN
       l_x_axis:=2.69695509354;
       l_y_axis:=-0.89490162322;
       l_z_axis:=-3.533973456;
       l_degrade_x_axis:=7.455678799;
       l_degrade_y_axis:=-3.678867756;
       l_degrade_z_axis:=-9.678345345;
       l_part_name:=G_EQP1_PART_NAME;
    ELSIF(P_EQP_NAME = G_EQP2_NAME)THEN
       l_x_axis:=1.69695509354;
       l_y_axis:=-0.59490162322;
       l_z_axis:=-2.533973456;
       l_degrade_x_axis:=6.455678799;
       l_degrade_y_axis:=-2.678867756;
       l_degrade_z_axis:=-8.678345345;  
       l_part_name:=G_EQP2_PART_NAME;
    ELSE
       l_x_axis:=3.69695509354;
       l_y_axis:=-1.59490162322;
       l_z_axis:=-4.533973456;
       l_degrade_x_axis:=9.455678799;
       l_degrade_y_axis:=-12.678867756;
       l_degrade_z_axis:=-13.678345345;
       l_part_name:=G_EQP3_PART_NAME;
    END IF;
    
    G_LOW_TOLERANCE:=round(DBMS_RANDOM.value(.9,.95),3);    -- -ve 10 to 5% tolerance
    G_HIGH_TOLERANCE:=round(DBMS_RANDOM.value(1.1,1.05),3); -- +ve 10 to 5% torerance
    
    --GENERATE EQP1 NORMAL_OP_30_DEG_C DATA  
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_NORMAL,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_NORMAL,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_NORMAL,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_NORMAL,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 OVER_CURRENT_FAULT_OP DATA
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_CURR,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_CURR,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_CURR,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_CURR,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 OVER_TEMP_FAULT_OP DATA
  
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_TEMP,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_TEMP,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_TEMP,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_TEMP,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 INPUT_OVER_VOLT_FAULT_OP DATA
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_VOLT,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_VOLT,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_VOLT,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_OVER_VOLT,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 ABNORMAL_OP_30_DEG_C DATA
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_AB_OP30_DEG,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_AB_OP30_DEG,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_AB_OP30_DEG,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_AB_OP30_DEG,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 BEARING_DEGRADE_OP DATA
    --load +/- 10% of X-AXIS
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_BERING_DEG_OP,G_DEGRADE_INT_TEMP,
                          G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                          l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_X_AXIS);
    
    --load +/- 10% of Y-AXIS
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_BERING_DEG_OP,G_DEGRADE_INT_TEMP,
                          G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                          l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_Y_AXIS);
                          
    --load +/- 10% of Z-AXIS
    insert_train_set_recs(P_EQP_NAME,l_part_name,G_LABEL_BERING_DEG_OP,G_DEGRADE_INT_TEMP,
                          G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                          l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_Z_AXIS);
                          
    
  END generate_eqp_train_set;
  
  --Procedure to insert tabel SENSOR_TEST_DATA with Test Set data.
  PROCEDURE insert_test_set_recs(p_eqp_name VARCHAR2,p_part_name VARCHAR2,p_serial_no VARCHAR2,p_label VARCHAR2,p_int_amb_temp NUMBER,
                                  p_ext_amb_temp NUMBER,p_input_cur NUMBER,p_input_volt NUMBER,
                                  p_x_axis NUMBER,p_y_axis NUMBER,p_z_axis NUMBER,p_param_to_update VARCHAR2) IS
                                  
  l_eqp_name      varchar2(60);
  l_part_name     varchar2(60);
  l_label         varchar2(60);
  l_serial_no     varchar2(60);
  l_int_amb_temp  number; 
  l_ext_amb_temp  number;
  l_input_cur     number; 
  l_input_volt    number; 
  l_vib_x_axis    number; 
  l_vib_y_axis    number;
  l_vib_z_axis    number;
  l_low_val       number;
  l_high_val      number;
  l_variable_val  number;
  
  BEGIN
    l_eqp_name:=p_eqp_name;
    l_part_name:=p_part_name;
    l_label:=p_label;
    l_serial_no:=p_serial_no;
    l_int_amb_temp:=p_int_amb_temp;
    l_ext_amb_temp:=p_ext_amb_temp;
    l_input_cur:=p_input_cur;
    l_input_volt:=p_input_volt;
    l_vib_x_axis:=p_x_axis;
    l_vib_y_axis:=p_y_axis;
    l_vib_z_axis:=p_z_axis;
                          
    if(G_FEATURE_INT_AMB_TEMP = p_param_to_update)then
      l_low_val:= l_int_amb_temp*G_LOW_TOLERANCE;
      l_high_val:= l_int_amb_temp*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_variable_val,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_EXT_AMB_TEMP = p_param_to_update)then
      l_low_val:= l_ext_amb_temp*G_LOW_TOLERANCE;
      l_high_val:= l_ext_amb_temp*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_variable_val,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_INPUT_CUR = p_param_to_update)then
      l_low_val:= l_input_cur*G_LOW_TOLERANCE;
      l_high_val:= l_input_cur*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_ext_amb_temp,l_variable_val,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_INPUT_VOLT = p_param_to_update)then
      l_low_val:= l_input_volt*G_LOW_TOLERANCE;
      l_high_val:= l_input_volt*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_variable_val,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    elsif(G_FEATURE_X_AXIS = p_param_to_update)then
      l_low_val:= l_vib_x_axis*G_LOW_TOLERANCE;
      l_high_val:= l_vib_x_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_variable_val,l_vib_y_axis,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
     elsif(G_FEATURE_X_AXIS = p_param_to_update)then
      l_low_val:= l_vib_y_axis*G_LOW_TOLERANCE;
      l_high_val:= l_vib_y_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_variable_val,l_vib_z_axis,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
      elsif(G_FEATURE_X_AXIS = p_param_to_update)then
      l_low_val:= l_vib_z_axis*G_LOW_TOLERANCE;
      l_high_val:= l_vib_z_axis*G_HIGH_TOLERANCE;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TEST_DATA (RECORD_ID,EQP_NAME,PART_NUMBER,SERIAL_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE,DATA_COLLECTION_TIME) VALUES 
        (SENSOR_REC_ID_S.NEXTVAL,l_eqp_name,l_part_name,l_serial_no,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_variable_val,l_label,sysdate,sysdate);
        l_variable_val:=l_variable_val+G_STEP_SIZE;
      end loop;
    end if;
  
  END insert_test_set_recs;

  --Procedure to generate test set data. 
  --Parameter: P_EQP_NAME:  This parameter decides for which equipment to generate data
  --           P_SERIAL_NO: This parameter decided for which serial number to generate data
  PROCEDURE genereate_eqp_test_set(P_EQP_NAME   VARCHAR2,P_SERIAL_NO VARCHAR2,P_RUN_COUNT  NUMBER) IS
    l_x_axis               NUMBER;
    l_Y_axis               NUMBER;
    l_Z_axis               NUMBER;
    l_degrade_x_axis       NUMBER;
    l_degrade_Y_axis       NUMBER;
    l_degrade_Z_axis       NUMBER;
    l_part_name            VARCHAR2(60);

  BEGIN
    
    IF(P_EQP_NAME = G_EQP1_NAME)THEN
       l_x_axis:=2.69695509354;
       l_y_axis:=-0.89490162322;
       l_z_axis:=-3.533973456;
       l_degrade_x_axis:=7.455678799;
       l_degrade_y_axis:=-3.678867756;
       l_degrade_z_axis:=-9.678345345;
       l_part_name:=G_EQP1_PART_NAME;
    ELSIF(P_EQP_NAME = G_EQP2_NAME)THEN
       l_x_axis:=1.69695509354;
       l_y_axis:=-0.59490162322;
       l_z_axis:=-2.533973456;
       l_degrade_x_axis:=6.455678799;
       l_degrade_y_axis:=-2.678867756;
       l_degrade_z_axis:=-8.678345345;  
       l_part_name:=G_EQP2_PART_NAME;
    ELSE
       l_x_axis:=3.69695509354;
       l_y_axis:=-1.59490162322;
       l_z_axis:=-4.533973456;
       l_degrade_x_axis:=9.455678799;
       l_degrade_y_axis:=-12.678867756;
       l_degrade_z_axis:=-13.678345345;
       l_part_name:=G_EQP3_PART_NAME;
    END IF;
    
    G_LOW_TOLERANCE:=round(DBMS_RANDOM.value(.9,.95),3);    -- -ve 10 to 5% tolerance
    G_HIGH_TOLERANCE:=round(DBMS_RANDOM.value(1.1,1.05),3); -- +ve 10 to 5% toreran
    
    --if run = 1,2 insert normal records. Anything more than 1 or 2 , insert degrade records
    -- G_EQP1_SERIAL3 IS NOT WORING NORMALLY
    IF(P_SERIAL_NO = G_EQP1_SERIAL1 OR P_SERIAL_NO = G_EQP1_SERIAL2 ) THEN 
      --GENERATE EQP1 NORMAL_OP_30_DEG_C DATA  
      --load +/- 10% of INT_AMB_TEMP
      insert_test_set_recs(P_EQP_NAME,l_part_name,p_serial_no,null,G_NRM_INT_TEMP,
                            G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                            l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
      
      --load +/- 10% of EXT_AMB_TEMP
      insert_test_set_recs(P_EQP_NAME,l_part_name,p_serial_no,null,G_NRM_INT_TEMP,
                            G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                            l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);            
      --load +/- 10% of INPUT_CUR
      insert_test_set_recs(P_EQP_NAME,l_part_name,p_serial_no,null,G_NRM_INT_TEMP,
                            G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                            l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
      
      --load +/- 10% of INPUT_VOLT
      insert_test_set_recs(P_EQP_NAME,l_part_name,p_serial_no,null,G_NRM_INT_TEMP,
                            G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                            l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                            
      RETURN;
    
    END IF;                      
    --GENERATE PART1 OVER_CURRENT_FAULT_OP DATA
    --load +/- 10% of INT_AMB_TEMP      
    IF(( P_RUN_COUNT >=1 AND P_SERIAL_NO = G_EQP1_SERIAL5 )OR ( P_RUN_COUNT >=3 AND P_SERIAL_NO = G_EQP1_SERIAL4 )
       OR ( P_RUN_COUNT >=4 AND P_SERIAL_NO = G_EQP1_SERIAL10 )) THEN 
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    --load +/- 10% of EXT_AMB_TEMP
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_OVER_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    RETURN; 
    END IF;                      
    --GENERATE PART1 OVER_TEMP_FAULT_OP DATA
    --load +/- 10% of INT_AMB_TEMP      
    IF(  ( P_SERIAL_NO = G_EQP1_SERIAL11 AND  P_RUN_COUNT =1)OR P_SERIAL_NO = G_EQP1_SERIAL12 OR P_SERIAL_NO = G_EQP1_SERIAL15 ) THEN 
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
                          
    --load +/- 10% of EXT_AMB_TEMP
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_OVER_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
      RETURN;   
    END IF;           
    --GENERATE PART1 INPUT_OVER_VOLT_FAULT_OP DATA
    --load +/- 10% of INT_AMB_TEMP -- G_EQP1_OVER_VOLT
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
     insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_NRM_EXT_TEMP,G_NRM_CUR,G_OVER_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 ABNORMAL_OP_30_DEG_C DATA
    
    --load +/- 10% of INT_AMB_TEMP
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INT_AMB_TEMP);
                          
    --load +/- 10% of EXT_AMB_TEMP
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_NRM_INT_TEMP,
                          G_OVER_EXT_TEMP,G_NRM_CUR,G_NRM_VOLT,
                          l_x_axis,l_y_axis,l_z_axis,G_FEATURE_INPUT_VOLT);
                        
                         
    --GENERATE PART1 BEARING_DEGRADE_OP DATA
    --load +/- 10% of X-AXIS
    IF(    ( P_SERIAL_NO = G_EQP1_SERIAL3 AND P_RUN_COUNT >=1) 
        OR ( P_SERIAL_NO = G_EQP1_SERIAL7 AND P_RUN_COUNT >=2)
        OR ( P_SERIAL_NO = G_EQP1_SERIAL8 AND P_RUN_COUNT >=1)
        OR ( P_SERIAL_NO = G_EQP1_SERIAL9 AND P_RUN_COUNT >=3)
        OR ( P_SERIAL_NO = G_EQP1_SERIAL6 AND P_RUN_COUNT >=1)
        ) THEN 
      insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_DEGRADE_INT_TEMP,
                            G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                            l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_X_AXIS);
      
      --load +/- 10% of Y-AXIS
      insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_DEGRADE_INT_TEMP,
                            G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                            l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_Y_AXIS);
                            
      --load +/- 10% of Z-AXIS
      insert_test_set_recs(P_EQP_NAME,l_part_name,P_SERIAL_NO,null,G_DEGRADE_INT_TEMP,
                            G_DEGRADE_EXT_TEMP,G_DEGRADE_CUR,G_DEGRADE_VOLT,
                            l_degrade_x_axis,l_degrade_y_axis,l_degrade_z_axis,G_FEATURE_Z_AXIS);
    END IF;
    
  END genereate_eqp_test_set;
  
  --Procedure which in turn calls procedure genereate_eqp_test_set muttiple times to generate Test Data
  PROCEDURE generate_test_set IS
  BEGIN
   G_STEP_SIZE:=3;
   -- generate random test data
   FOR I IN 1..10 LOOP
   
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL3,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL7,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL9,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL10,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL11,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL12,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL13,I);
    
    genereate_eqp_test_set(G_EQP2_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP2_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP2_NAME,G_EQP1_SERIAL3,I);
    genereate_eqp_test_set(G_EQP3_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP3_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP3_NAME,G_EQP1_SERIAL3,I);
       
   END LOOP;
   
   FOR I IN 1..2 LOOP
   
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL3,I);
    --genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    --genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL7,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL9,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL15,I);
   END LOOP;
   
   FOR I IN 1..3 LOOP
   
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL3,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL7,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL9,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL15,I);
   END LOOP;
   
   FOR I IN 1..4 LOOP
   
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL1,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL2,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL3,I);
    --genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    --genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL7,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL9,I);
   END LOOP;
   
   FOR I IN 1..4 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
   END LOOP;
   
   FOR I IN 1..4 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL6,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL8,I);
   END LOOP;
   
   FOR I IN 1..4 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
   END LOOP;
   
   FOR I IN 1..4 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL4,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL5,I);
   END LOOP;
   
   FOR I IN 1..2 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL11,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL15,I);
   END LOOP;
   
   FOR I IN 3..6 LOOP
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL12,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL13,I);
    genereate_eqp_test_set(G_EQP1_NAME,G_EQP1_SERIAL14,I);
   END LOOP;
    
    
    COMMIT;
  END generate_test_set;
  
  --Procedure which in turn calls procedure generate_eqp_train_set muttiple times to generate Test Data
  PROCEDURE generate_train_set IS
  BEGIN
    -- Generate training sets
    G_STEP_SIZE:=.1;
    FOR I IN 1..12 LOOP
      generate_eqp_train_set(G_EQP1_NAME);
      generate_eqp_train_set(G_EQP2_NAME);
      generate_eqp_train_set(G_EQP3_NAME);
    END LOOP;
    
    COMMIT;
  END generate_train_set;
  
  --Procedure to delete Training and Testing Data
  PROCEDURE delete_train_set IS
  BEGIN
    DELETE FROM SENSOR_TRAIN_DATA;
    DELETE FROM SENSOR_TEST_DATA;
    COMMIT;
  END delete_train_set;
  
END BIG_DATA_503_PRJ_PKG;