public class Task_SCH01_BatchNotify implements Schedulable {
    Decimal heure_debut_Manager1 = 2;
    Decimal heure_fin_Manager1 = 3;
    Decimal heure_debut_Manager2 = 3;
    
    public Task_SCH01_BatchNotify(Decimal heure_debut_Manager1,Decimal heure_fin_Manager1,Decimal heure_debut_Manager2){
        this.heure_debut_Manager1 = heure_debut_Manager1;
        this.heure_fin_Manager1 = heure_fin_Manager1;
        this.heure_debut_Manager2 = heure_debut_Manager2;
    }
    public void execute(SchedulableContext ctx) {
        
        
        Task_BA01_NotifyManager batchNotifyManager = new Task_BA01_NotifyManager(heure_debut_Manager1,heure_fin_Manager1,heure_debut_Manager2);
        ID batchprocessid = Database.executeBatch(batchNotifyManager);
    }
}