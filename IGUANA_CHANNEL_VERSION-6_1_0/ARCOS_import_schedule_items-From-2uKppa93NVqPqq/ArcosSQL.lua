local ArcosSQL = {}


function ArcosSQL.queryScheduleItemsArcos()

ArcosScheduleItemInfo = [[ select * from ArcosMDB.dbo.schedule_item]]
   
--UpdateScheduleItems =[[ update ArcosMDB.dbo.schedule_item Set lic_reqd ="..ItemDataFromElite[i].lic_reqd..",sched1 ="..ItemDataFromElite[i].sched1..",sched2 ="..ItemDataFromElite[i].sched2..",sched3 ="..ItemDataFromElite[i].sched3..",sched4 ="..ItemDataFromElite[i].sched4..",sched5 ="..ItemDataFromElite[i].sched5..",sched6 ="..ItemDataFromElite[i].sched6..",sched7 ="..ItemDataFromElite[i].sched7..",sched8 ="..ItemDataFromElite[i].sched8..",baccs ="..(ItemDataFromElite[i].BACCS)..",break_code ="..ItemDataFromElite[i].break_code..",use_break_code ="..ItemDataFromElite[i].use_break_code..",upc ="..ItemDataFromElite[i].upc..",desc_1 ="..ItemDataFromElite[i].desc_1..",row_update_stp =GETDATE(),row_update_user_id ='Iguana User' Where item_num ="..ItemDataFromElite[i].ITEM_NUM.." ]]

end


return ArcosSQL