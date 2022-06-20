public class Task_BA01_NotifyManager implements Database.Batchable<sObject>{
    String query;
    BusinessHours defaultBH = [SELECT Id FROM BusinessHours WHERE IsDefault = true Limit 1];
    OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'smeia.contact@gmail.com' Limit 1];
	Decimal heure_debut_Manager1;
    Decimal heure_fin_Manager1;
    
    Decimal heure_debut_Manager2;

    public Task_BA01_NotifyManager(Decimal heure_debut_Manager1,Decimal heure_fin_Manager1,Decimal heure_debut_Manager2){
       this.heure_debut_Manager1 = heure_debut_Manager1;
       this.heure_fin_Manager1 = heure_fin_Manager1;
       this.heure_debut_Manager2 = heure_debut_Manager2;
    }
    public Database.querylocator start(Database.BatchableContext BC){
        query = 'SELECT id,CreatedDate,Email_Manager_N_1__c,Email_Manager_N_2__c,Manager_N_1_Notified__c,Manager_N_2_Notified__c FROM Task WHERE (is_webLead_Task__c = true and Status != \'completed\') '
            +'And ((Email_Manager_N_1__c <> null And Manager_N_1_Notified__c = false ) OR (Email_Manager_N_2__c <> null And Manager_N_2_Notified__c = false)) ';

        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Task> tasks = new List<Task>();
        String param;

        if(defaultBH != NULL){   
            for(sObject s : scope){
                Task task = (Task)s;
                param = task.CreatedDate.format()+';'+Datetime.now().format()+';'+defaultBH.id;     
                List<Decimal> delais = AX01_TempsEcoule.calculeDelaiDeCloture(new list<String>{param});
                decimal TempsEcoule = delais.get(0);
                if((TempsEcoule>=this.heure_debut_Manager1  && TempsEcoule < this.heure_fin_Manager1) && (task.Email_Manager_N_1__c != null && task.Manager_N_1_Notified__c == false)){
                    sendEmail(task.Email_Manager_N_1__c,task.id,1); 
                    tasks.add(new Task(id =task.id ,Manager_N_1_Notified__c = true ));        
                }else if((TempsEcoule >= this.heure_debut_Manager2 && task.Email_Manager_N_2__c != null) && task.Manager_N_2_Notified__c == false){
                    sendEmail(task.Email_Manager_N_2__c,task.id,2); 
                    tasks.add(new Task(id =task.id ,Manager_N_2_Notified__c = true ));        
                }
            }
            if(tasks.size()>0)
                update tasks;     
        }  
        
    }
    public void sendEmail(string email,String taskId,Integer order){
        String msg = 'Task on hold : No activity had been detected for the task '+ URL.getSalesforceBaseUrl().toExternalForm()+ '/'+taskId+ ' for more than ';
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        if ( owea != null ) {
            message.setOrgWideEmailAddressId(owea.Id);
        }
        
        if(order == 1)
            msg += this.heure_debut_Manager1  +' hours.';
        else if(order == 2)
            msg += this.heure_debut_Manager2+' hours.';
        system.debug('msg '+msg);
        message.toAddresses = new String[]{email};
        message.optOutPolicy = 'FILTER';
        message.subject = 'Warrning Activity Alert ';
        message.plainTextBody = msg;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        
    }
    public void finish(Database.BatchableContext BC){
    }
}