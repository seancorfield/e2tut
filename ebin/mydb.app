{application,mydb,
             [{description,"mydb app"},
              {vsn,"1"},
              {modules,[mydb,mydb_app,mydb_db,mydb_server]},
              {registered,[]},
              {mod,{e2_application,[mydb_app]}},
              {env,[]},
              {applications,[kernel,stdlib]}]}.
