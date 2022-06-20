@isTest
public class Test_Task_BA01_NotifyManager {
    @testsetup
    static void setup(){
        
        Lead l = new Lead();
        l.Salutation = 'Mr';
        l.FirstName='test';
        l.LastName='test';
        l.Email = 'semia.contact@gmail.com';
        l.Company='NBS Consulting';
        l.leadsource='Website';
        l.Affectation_web__c = 'commercial';
        l.is_Web__c = true;
        l.Showroom__c = 'Smeia - Casablanca';
        l.Type_d_interet_du_prospect__c = 'VN';
        l.MobilePhone = '+212634567873';
        l.Marque_d_interet__c = 'BMW';
        l.Serie_Modele__c = 'Série 1';
        insert l;
        
        Task task = new Task();
        task.subject = 'Qualification d\'un prospect web';
        task.is_webLead_Task__c = true;
        task.WhoId = l.id;
        task.Email_Manager_N_1__c = 'semia.contact@gmail.com';
        task.Email_Manager_N_2__c = 'semia.contact@gmail.com';
        insert task;
    }
    
    @isTest
    static void notifymanagerTest(){
        
        Test.startTest();
        Task_SCH01_BatchNotify obj = new Task_SCH01_BatchNotify(0,1,2);   
        String chron = '0 0 23 * * ?';        
        String jobid = System.schedule('testNotifyManager1', chron, obj);
        obj.execute(null);

        obj = new Task_SCH01_BatchNotify(1,2,0);   
        chron = '0 0 23 * * ?';        
        jobid = System.schedule('testNotifyManager2', chron, obj);
        obj.execute(null);
        Test.stopTest();
        
        Task task = [select id,Manager_N_1_Notified__c,Manager_N_2_Notified__c from Task limit 1];
        system.assertEquals(true, task.Manager_N_1_Notified__c);
        system.assertEquals(true, task.Manager_N_2_Notified__c);
        
    }
    
}