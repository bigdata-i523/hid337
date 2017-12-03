create or replace PACKAGE BIG_DATA_503_PRJ_PKG AS
  /*
     Description:
         This pl/sql Package contains needed procedures for generation of 
         Test/Training Data needed for the final project of i523 Big Data Analytics Course
      
     Date           Author           Comments
     12/01/2017     HID337,HID333    Initial version
  
  */
  
  --New pl/sql types for integration with python code
  TYPE num_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
  TYPE string_array IS TABLE OF VARCHAR2(120) INDEX BY PLS_INTEGER;
  
  --This procedure gets called from python code to update test data with labels
  PROCEDURE update_testdata_labels(p_id_list IN NUM_ARRAY,p_result_list string_array);
  
  --Procedure to generate training set data
  PROCEDURE generate_train_set;
  
  --Procedure to generate test set datae
  PROCEDURE generate_test_set;
  
  --Procedure to delete training and test data
  PROCEDURE delete_train_set;
  
END BIG_DATA_503_PRJ_PKG;