create or replace PACKAGE BODY BIG_DATA_503_PRJ_PKG AS
  
  G_FEATURE_INT_AMB_TEMP  VARCHAR2(60):='INT_AMB_TEMP';
  G_FEATURE_EXT_AMB_TEMP  VARCHAR2(60):='EXT_AMB_TEMP';
  G_FEATURE_INPUT_CUR     VARCHAR2(60):='INTPUT_CUR';
  G_FEATURE_INPUT_VOLT    VARCHAR2(60):='INTPUT_VOLT';
  G_FEATURE_X_AXIS        VARCHAR2(60):='VIB_X_AXIS';
  G_FEATURE_Y_AXIS        VARCHAR2(60):='VIB_Y_AXIS';
  G_FEATURE_Z_AXIS        VARCHAR2(60):='VIB_Z_AXIS';
  
  PROCEDURE update_testdata_labels(p_id_list IN NUM_ARRAY,p_result_list string_array) IS
  BEGIN
   
    FOR i IN 1..p_id_list.COUNT 
    LOOP
       /*update KNN_TEST_DATA
       set label = p_result_list(i)
       where record_id = p_id_list(i);*/
       NULL;
    END LOOP ;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END update_testdata_labels; 
  
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
  l_step_size     number:=0.01;
  
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
      l_low_val:= l_int_amb_temp*.9;
      l_high_val:= l_int_amb_temp*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_variable_val,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+l_step_size;
      end loop;
    elsif(G_FEATURE_EXT_AMB_TEMP = p_param_to_update)then
      l_low_val:= l_ext_amb_temp*.9;
      l_high_val:= l_ext_amb_temp*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_variable_val,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+l_step_size;
      end loop;
    elsif(G_FEATURE_INPUT_CUR = p_param_to_update)then
      l_low_val:= l_input_cur*.9;
      l_high_val:= l_input_cur*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_variable_val,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+l_step_size;
      end loop;
    elsif(G_FEATURE_INPUT_VOLT = p_param_to_update)then
      l_low_val:= l_input_volt*.9;
      l_high_val:= l_input_volt*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_variable_val,l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+l_step_size;
      end loop;
    elsif(G_FEATURE_X_AXIS = p_param_to_update)then
      l_low_val:= l_vib_x_axis*.9;
      l_high_val:= l_vib_x_axis*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val < l_high_val) 
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_variable_val,l_vib_y_axis,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+l_step_size;
      end loop;
    elsif(G_FEATURE_Y_AXIS = p_param_to_update)then
      l_low_val:= l_vib_y_axis*.9;
      l_high_val:=l_vib_y_axis*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val > l_high_val) -- y axis is -ve
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_variable_val,l_vib_z_axis,l_label,sysdate);
        l_variable_val:=l_variable_val+(-1*l_step_size);
      end loop;
    elsif(G_FEATURE_Z_AXIS = p_param_to_update)then
      l_low_val:= l_vib_z_axis*.9;
      l_high_val:=l_vib_z_axis*1.1;
      l_variable_val:=l_low_val;
      while (l_variable_val > l_high_val) -- z axis is -ve
      loop
        INSERT INTO SENSOR_TRAIN_DATA (EQP_NAME,PART_NUMBER,INT_AMB_TEMP,EXT_AMB_TEMP,INPUT_CUR,INPUT_VOLT,VIB_X_AXIS,VIB_Y_AXIS,VIB_Z_AXIS,LABEL,CREATION_DATE) VALUES 
        (l_eqp_name,l_part_name,l_int_amb_temp,l_ext_amb_temp,l_input_cur,l_input_volt,l_vib_x_axis,l_vib_y_axis,l_variable_val,l_label,sysdate);
        l_variable_val:=l_variable_val+(-1*l_step_size);
      end loop;
    end if;
  
  END insert_train_set_recs;
  
  PROCEDURE generate_train_set IS
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
  
  BEGIN
   
    --GENERATE PART1 NORMAL_OP_30_DEG_C DATA  
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='NORMAL_OP_30_DEG_C';
    l_int_amb_temp:=40;
    l_ext_amb_temp:=30;
    l_input_cur:=12;
    l_input_volt:=115;
    l_vib_x_axis:=2.696955094;
    l_vib_y_axis:=-0.894901623;
    l_vib_z_axis:=-3.533973456;
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 OVER_CURRENT_FAULT_OP DATA
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='OVER_CURRENT_FAULT_OP';
    l_int_amb_temp:=40;
    l_ext_amb_temp:=30;
    l_input_cur:=20;
    l_input_volt:=115;
    l_vib_x_axis:=2.696955094;
    l_vib_y_axis:=-0.894901623;
    l_vib_z_axis:=-3.533973456;
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 OVER_TEMP_FAULT_OP DATA
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='OVER_TEMP_FAULT_OP';
    l_int_amb_temp:=90;
    l_ext_amb_temp:=30;
    l_input_cur:=12;
    l_input_volt:=115;
    l_vib_x_axis:=2.696955094;
    l_vib_y_axis:=-0.894901623;
    l_vib_z_axis:=-3.533973456;
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 INPUT_OVER_VOLT_FAULT_OP DATA
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='INPUT_OVER_VOLT_FAULT_OP';
    l_int_amb_temp:=40;
    l_ext_amb_temp:=30;
    l_input_cur:=12;
    l_input_volt:=135;
    l_vib_x_axis:=2.696955094;
    l_vib_y_axis:=-0.894901623;
    l_vib_z_axis:=-3.533973456;
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 ABNORMAL_OP_30_DEG_C DATA
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='ABNORMAL_OP_30_DEG_C';
    l_int_amb_temp:=50;
    l_ext_amb_temp:=45;
    l_input_cur:=18;
    l_input_volt:=120;
    l_vib_x_axis:=2.696955094;
    l_vib_y_axis:=-0.894901623;
    l_vib_z_axis:=-3.533973456;
    
    --load +/- 10% of INT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INT_AMB_TEMP);
    
    --load +/- 10% of EXT_AMB_TEMP
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_EXT_AMB_TEMP);
                          
    --load +/- 10% of INPUT_CUR
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_CUR);
    
    --load +/- 10% of INPUT_VOLT
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_INPUT_VOLT);
                          
    --GENERATE PART1 BEARING_DEGRADE_OP DATA
    l_eqp_name:='Vacuum Blower';
    l_part_name:='38000-010';
    l_label:='BEARING_DEGRADE_OP';
    l_int_amb_temp:=90;
    l_ext_amb_temp:=50;
    l_input_cur:=18;
    l_input_volt:=120;
    l_vib_x_axis:=7.455678799;
    l_vib_y_axis:=-3.678867756;
    l_vib_z_axis:=-9.678345345;
    
    --load +/- 10% of X-AXIS
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_X_AXIS);
    
    --load +/- 10% of Y-AXIS
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_Y_AXIS);
                          
    --load +/- 10% of Z-AXIS
    insert_train_set_recs(l_eqp_name,l_part_name,l_label,l_int_amb_temp,
                          l_ext_amb_temp,l_input_cur,l_input_volt,
                          l_vib_x_axis,l_vib_y_axis,l_vib_z_axis,G_FEATURE_Z_AXIS);
                             
  END generate_train_set;
  
  PROCEDURE genereate_test_set IS
  BEGIN
    NULL;
  END genereate_test_set;
  
  PROCEDURE delete_train_set IS
  BEGIN
    DELETE FROM SENSOR_TRAIN_DATA;
  END delete_train_set;
  
END BIG_DATA_503_PRJ_PKG;