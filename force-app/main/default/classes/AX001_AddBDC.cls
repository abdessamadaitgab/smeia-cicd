public with sharing class AX001_AddBDC {
    @InvocableMethod
    public static  list<Quote> CreationBonDeCommande(list<string> oppIds){

        //creation de BDC
        String oppId = oppIds[0];
        Opportunity opp = [SELECT id,Name FROM Opportunity  WHERE Id =: oppId];

        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get('Bon_de_commande').getRecordTypeId();
        Quote bdc = new quote(Name = 'BDC-'+opp.Name,
        RecordTypeId =recordTypeId,OpportunityId=oppId);
        User currentUser = [SELECT id,Showroom__c
        FROM User
        WHERE id=: UserInfo.getUserId()];

        list<User> approbateurs = [SELECT id,UserRole.DeveloperName, Email 
        FROM User
        WHERE (Showroom__c =: currentUser.Showroom__c 
        And (UserRole.DeveloperName LIKE '%ADV%' OR 
        UserRole.DeveloperName LIKE '%Chef_de_ventes%' OR
        UserRole.DeveloperName LIKE '%Directeur_de_site%'))
        OR    UserRole.DeveloperName = 'National' OR UserRole.DeveloperName = 'Finance'
        OR    UserRole.DeveloperName = 'Chef_de_service_ordering' OR UserRole.DeveloperName = 'Directeur_Commercial'
        OR    UserRole.DeveloperName = 'Responsable_Achat_VO'];



        for (User user : approbateurs) {
            if(user.UserRole.DeveloperName == 'National'){
                bdc.National__c = user.Id;
                bdc.National_Email__c = user.Email;
            }else if(user.UserRole.DeveloperName.contains('ADV')){
                bdc.ADV_Ville__c = user.Id;
                bdc.ADV_Email__c = user.Email;
            }else if(user.UserRole.DeveloperName.contains('Chef_de_ventes')){
                bdc.CDV__c = user.Id;
                bdc.CDV_Email__c = user.Email;
            }else if(user.UserRole.DeveloperName.contains('Directeur_de_site')){
                bdc.DS__c = user.Id;
                bdc.DS_Email__c = user.Email;
            }else if(user.UserRole.DeveloperName == 'Finance'){
                bdc.Finance__c = user.Id;
            }else if(user.UserRole.DeveloperName == 'Chef_de_service_ordering'){
                bdc.Chef_de_service_ordering__c = user.Id;
            }else if(user.UserRole.DeveloperName == 'Directeur_Commercial'){
                bdc.Directeur_Commercial__c = user.Id;
            }else if(user.UserRole.DeveloperName == 'Responsable_Achat_VO'){
                bdc.Responsable_Achat_VO__c = user.Id;
            }

        }
        insert bdc;
        

       QuoteLineItem quoteLineItem = [SELECT id,Destockage__c,Promo__c,Discount,UnitPrice,Prix_de_vente_CEM_hors_DP__c, product2Id, PricebookEntryId,
       Prix_de_vente_CEM__c, Prix_plancher_VO_TTC__c, Droit_Proportionnel__c,
       Prix_Total_Options_TTC__c,Prix_vente_Options_TTC__c,Prix_public_TTC__c, Frais_d_immatriculation__c, 
       Prix_public_produit_TTC__c,Prix_vente_produit_TTC__c,N_de_plaque_VO__c,
       Remise_plancher_VO__c,Quantity,Remise_destockage_promo__c,OpportunityLineItemId
       FROM QuoteLineItem 
       WHERE Quote.status = 'Approuvé' and Quote.OpportunityId =: oppId and Quote.recordType.DeveloperName = 'Proforma'];

       QuoteLineItem bdcLineItem = quoteLineItem.clone(false, false, false, false);
       bdcLineItem.QuoteId = bdc.id;

       insert bdcLineItem; 

       return new list<Quote>{bdc};
    }
}