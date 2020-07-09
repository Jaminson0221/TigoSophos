SELECT DISTINCT *
FROM (select PL.NAME AS LISTA_PRECIOS,
             P.NAME AS PLAN, 
             '' AS PAQUETE, 
             PLI.EFF_START_DT AS FECHA_INI_VIGENCIA, 
             PLI.EFF_END_DT AS FECHA_FIN_VIGENCIA, 
             CAST(PLI.Std_Pri_Unit AS DECIMAL (10,2)) AS PRECIO_SIN_IVA, 
             CAST((PLI.Std_Pri_Unit + (PLI.Std_Pri_Unit * PLI.Tax_Val1)) AS DECIMAL (10,2)) AS PRECIO_CON_IVA,
             (PLI.Tax_Val1 * 100) AS IVA
      from ((siebel.s_pri_lst PL
       inner join siebel.s_pri_lst_item PLI on PLI.Pri_Lst_Id = PL.ROW_ID)
       inner join siebel.s_prod_int P on P.Row_Id = PLI.PROD_ID)
      where PLI.EFF_START_DT <= sysdate
       AND (PLI.EFF_END_DT IS NULL OR PLI.EFF_END_DT >= sysdate)
       AND P.type in ('Plan comercial', 'Paquete de canales')
       UNION ALL
       select  PL.NAME AS LISTA_PRECIOS, 
               P.NAME AS PLAN,
               PAQ.NAME AS PAQUETE,
               MT.EFF_START_DT AS FECHA_INI_VIGENCIA,
               MT.EFF_END_DT AS FECHA_FIN_VIGENCIA, 
               CAST (MT.ADJ_VAL_AMT AS DECIMAL(10,2)) AS PRECIO_SIN_IVA,
               CAST ((MT.ADJ_VAL_AMT + (MT.ADJ_VAL_AMT * PLI.Tax_Val1)) AS DECIMAL(10,2)) AS PRECIO_CON_IVA,
               (PLI.Tax_Val1 * 100) AS IVA
       from (((siebel.S_STDPROD_PMTRX MT
         inner join siebel.s_pri_lst PL on PL.Row_Id = MT.x_Price_Lst_Id)
         inner join siebel.s_prod_int P on P.row_id = MT.Prod_Id)
         inner join siebel.s_prod_int PAQ on PAQ.row_id = MT.x_Par_Prod_Promo_Id)
         inner join siebel.s_pri_lst_item PLI on (PLI.Pri_Lst_Id = PL.ROW_ID
                                                  AND PLI.Prod_Id = MT.Prod_Id 
                                                  AND PLI.EFF_START_DT <= sysdate
                                                  AND (PLI.EFF_END_DT IS NULL OR PLI.EFF_END_DT >= sysdate)
                                                  ) 
       where MT.EFF_START_DT <= sysdate
         AND (MT.EFF_END_DT IS NULL OR MT.EFF_END_DT >= sysdate)     
         AND P.type in ('Plan comercial', 'Paquete de canales')) PRECIOS
WHERE /*************** INGRESAR NOMBRE LISTA DE PRECIOS ***********/
      LISTA_PRECIOS = 'LP_Barrancabermeja_Residencial_Estrato4'
      /************** INGRESA NOMBRE DEL PLAN O PAQUETE PREMIUM ***/
      AND PLAN = 'Internet 60MB' 
      /**************/
ORDER BY 1,2,3;
 
 

 
