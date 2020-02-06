local DBConnection =  {}

function DBConnection.connectdb()

    if not conn_Arcos_stg or conn_Arcos_stg:check() then  --dev connection
        if conn_Arcos_stg and conn_Arcos_stg:check() then
            conn_Arcos_stg:close() end

    conn_Arcos_stg = db.connect{
        api=db.SQL_SERVER,
        name='SQLDEV',
        --name='SQLDRIVER',
        user='ARCOSIguana',      -- use empty string for integrated security
        password='ARCOS#%$@21Ig',  -- use empty string for integrated security
        -- name='SQLSTAGE',    -- this is for stage
        --name='SQLDRIVER',
        -- user='',      -- use empty string for integrated security
        --password='',  -- use empty string for integrated security
        use_unicode = true,
        live = true
    }
    end


    if not conn_Elite_qa or conn_Elite_qa:check() then  --dev connection
        if conn_Elite_qa and conn_Elite_qa:check() then
            conn_Elite_qa:close() end
    conn_Elite_qa = db.connect{
        api=db.ORACLE_OCI,
        name='//lqec0409val1d01.cardinalhealth.net:1521/val1d/',   --QA
        --name='//lsec0409val1s01.cardinalhealth.net:1521/val1s/',
        user='sps_service',
        password='mickey222',
        use_unicode = true,
        live = true
    }
    end




    --[[
   if not conn_dev or conn_dev:check() then  --dev connection
        if conn_dev and conn_dev:check() then
            conn_dev:close() end
        conn_dev = db.connect{
            api=db.MY_SQL,
            name='3pl_sps_ordering@ddec0609plord01.cdhhdsjj0b0x.us-east-1.rds.amazonaws.com:3306',
            user='online_order_app_master',
            password='Appmaster3pl',
            use_unicode = true,
            live = true
        }
    end
   ]]--

end

function DBConnection.Verify_DBConn_Elite()  --function for validating db connection
    return conn_Elite_qa:check()
end  --end Verify_DBConn_Elite() function



function DBConnection.Verify_DBConn_Arcos()  --function for validating db connection
    return conn_Arcos_stg:check()
end  --end Verify_DBConn_Arcos() function





return DBConnection
