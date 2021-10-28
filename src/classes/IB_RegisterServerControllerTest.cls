@isTest
public class IB_RegisterServerControllerTest {

    IBRegisterSetting__mdt setting;

    @isTest
    public static void checkGetNoEnrolments(){
        IBRegisterSetting__mdt setting = createSettings();
        sObject ev = createData(false, setting);
        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);
        system.assertEquals(0,wrappers.size());
    }

    @isTest
    public static void checkGetEnrolments(){
        IBRegisterSetting__mdt setting = createSettings();
        if(setting==null||setting.EnrolmentObject__c==null){
            system.assert(true);
        }else{
            sObject ev = createData(true, setting);
            Account account = new Account(  Name = 'acc' );
            insert account;
            Contact contact = new Contact(AccountId = account.Id, LastName = 'test');
            insert contact;
            Map<String, sObject> enrols = IB_RegisterServerController.getEnrolments(account.Id,setting);
            system.assertEquals(1,enrols.values().size());
        }
    }

    @isTest
    public static void checkGetPreviousAttended(){
        IBRegisterSetting__mdt setting = createSettings();
        sObject ev = createData(true, setting);
        sObject att = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).newSObject() ;
        att.put(setting.AttendanceEventLookupField__c,ev.Id);

        String enrolQuery = 'SELECT Id FROM '+setting.EnrolmentObject__c;
        sObject enrol = database.query(enrolQuery);
        att.put(setting.AttendanceEnrolmentLookupField__c,enrol.Id);


        String attendedStatus;

        if(setting.AttendanceStatusField__c!=null){ 
            attendedStatus = getAttStatus();
            att.put(setting.AttendanceStatusField__c,'Sent');
        }
        if(setting.AttendanceBooleanField__c!=null){
            att.put(setting.AttendanceBooleanField__c,true);
        }
        insert att;
 
        String attString = IB_RegisterServerController.getAttendees(ev.Id);
        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);

        if(setting.AttendanceStatusField__c!=null){
            system.assertEquals('Sent',wrappers[0].status);
        }
        if(setting.AttendanceBooleanField__c!=null){
            system.assertEquals(true,wrappers[0].statusBoolean);
        }        
    }

    @isTest
    public static void checkSave(){
        IBRegisterSetting__mdt setting = createSettings();
        IB_RegisterServerController.fields=createSettingFields();
        sObject ev = createData(true, setting);
        Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        CampaignMember member = new CampaignMember(
            ContactId = contact.Id,
            CampaignId = ev.Id,
            Status = 'Sent'
        );
        insert member;
        String attString = IB_RegisterServerController.getAttendees(ev.Id);

        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);

        for(IB_RegisterServerController.AttendanceWrapper wrapper: wrappers){
            if(setting.AttendanceStatusField__c!=null){                 
                wrapper.status = getAttStatus();
            }
            if(setting.AttendanceBooleanField__c!=null){
                wrapper.statusBoolean = true;
            }
        }
        

        IB_RegisterServerController.saveRecords(JSON.serialize(wrappers),IB_RegisterServerController.getEventWrapperString(ev.Id));

        String query = 'SELECT Id FROM '+setting.AttendanceObject__c+' WHERE ';
        if(setting.AttendanceStatusField__c!=null){
            query = query + setting.AttendanceStatusField__c + ' = \'Sent\'';
        }
        if(setting.AttendanceStatusField__c!=null&&setting.AttendanceBooleanField__c!=null){
            query = query + ' AND ';
        }
        if(setting.AttendanceBooleanField__c!=null){
            query = query + setting.AttendanceBooleanField__c + ' = true';
        }
        List<sObject> atts = database.query(query);

        system.assertEquals(1,atts.size());
    }


    @isTest
    public static void checkSaveAbsent(){
        IBRegisterSetting__mdt setting = createSettings();
        IB_RegisterServerController.fields=createSettingFields();
        sObject ev = createData(true, setting);
        Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        CampaignMember member = new CampaignMember(
            ContactId = contact.Id,
            CampaignId = ev.Id,
            Status = 'Sent'
        );
        insert member;
        String attString = IB_RegisterServerController.getAttendees(ev.Id);

        List<IB_RegisterServerController.AttendanceWrapper> wrappers =(List<IB_RegisterServerController.AttendanceWrapper>)System.JSON.deserialize(attString, List<IB_RegisterServerController.AttendanceWrapper>.class);

        for(IB_RegisterServerController.AttendanceWrapper wrapper: wrappers){
            if(setting.AttendanceStatusField__c!=null){                 
                wrapper.status = getAttStatus();
            }
            if(setting.AttendanceBooleanField__c!=null){
                wrapper.statusBoolean = false;
            }
        }
        
        IB_RegisterServerController.saveRecords(JSON.serialize(wrappers),IB_RegisterServerController.getEventWrapperString(ev.Id));

        String query = 'SELECT Id FROM '+setting.AttendanceObject__c+' WHERE ';
        if(setting.AttendanceStatusField__c!=null){
            query = query + setting.AttendanceStatusField__c + ' = \'Sent\'';
        }
        if(setting.AttendanceStatusField__c!=null&&setting.AttendanceBooleanField__c!=null){
            query = query + ' AND ';
        }
        if(setting.AttendanceBooleanField__c!=null){
            query = query + setting.AttendanceBooleanField__c + ' = false';
        }
        List<sObject> atts = database.query(query);

        system.assertEquals(1,atts.size());
    }

    @isTest
    public static void getFields(){
        IBRegisterSetting__mdt setting = createSettings();
        IB_RegisterServerController.fields = createSettingFields();        
        List<IB_RegisterServerController.FieldWrap> wrappers = (List<IB_RegisterServerController.FieldWrap>)System.JSON.deserialize(
            IB_RegisterServerController.returnFields('setting'), 
            List<IB_RegisterServerController.FieldWrap>.class
        );
        system.assertEquals(2,wrappers.size());
    }

    @isTest
    public static void getNoOptions(){
        IBRegisterSetting__mdt setting = createSettings();
        setting.AttendanceStatusField__c=null;
        IB_RegisterServerController.setting = setting;
        system.assertEquals(null, IB_RegisterServerController.getStatusOptions());
    }

    @isTest
    public static void saveEvent(){
        IBRegisterSetting__mdt setting = createSettings();
        sObject ev = createData(true, setting);
        IB_RegisterServerController.EventWrapper wrapper = new IB_RegisterServerController.EventWrapper();
        wrapper.notes = 'NOTES';
        IB_RegisterServerController.saveEvent(setting,ev,wrapper);

        Campaign event = [SELECT Id, StartDate, Description FROM Campaign WHERE Id =: ev.Id];
        system.assertEquals(system.today(),event.StartDate);
        system.assertEquals('NOTES',event.Description);

    }

    public static String getAttStatus(){
            Map<String,String> options = IB_RegisterServerController.getStatusOptions();
            List<String> keys = new List<String>(options.keySet());
            return options.get(keys[0]);
    }

    public static sObject createData(Boolean addEnrol, IBRegisterSetting__mdt setting){

        /* ProgrammeTestData progData = new ProgrammeTestData();
        sObject prog =  progData.insertProgramme();*/
        
        sObject prog;
        if(setting.ProgrammeObject__c!=null){
            prog = Schema.getGlobalDescribe().get(setting.ProgrammeObject__c).newSObject() ;
            prog.put('Name', 'Prog');
            insert prog;
        }

        sObject ev = Schema.getGlobalDescribe().get(setting.EventObject__c).newSObject();
        ev.put('Name', 'Event');
        if(setting.ProgrammeObject__c!=null&&setting.EventProgrammeLookupField__c!=null){
            ev.put(setting.EventProgrammeLookupField__c,prog.Id);
        }
        if(setting.EventDateField__c!=null){
            ev.put(setting.EventDateField__c,system.today());
        }
        if(setting.EventDateField__c!=null){
            ev.put(setting.EventDateTimeField__c,system.now());
        }
        if(setting.EventTimeField__c!=null){
            ev.put(setting.EventTimeField__c,system.now().time());
        }
        insert ev;

        if(addEnrol&&setting.EnrolmentObject__c!=null){
            sObject enrol = Schema.getGlobalDescribe().get(setting.EnrolmentObject__c).newSObject();
            if(setting.EnrolmentObject__c=='Contact'){
                enrol.put('LastName', 'Enrol');
            }else{
                enrol.put('Name', 'Enrol');
            }
            enrol.put(setting.EnrolmentProgrammeLookupField__c,prog.Id);
            insert enrol;
        }
        return ev;
    }

    private static IBRegisterSetting__mdt createSettings(){
        IB_RegisterServerController.setting =  new IBRegisterSetting__mdt(
            Label = 'setting',
            DeveloperName = 'setting',
            EventObject__c = 'Campaign',
            EventTitleField__c = 'Name',
            AttendanceObject__c = 'CampaignMember',
            AttendanceStatusField__c = 'Status',
            AttendanceEventLookupField__c = 'CampaignId',
            EnrolmentObject__c = 'Contact',
            AttendanceEnrolmentLookupField__c = 'ContactId',
            EnrolmentProgrammeLookupField__c = 'AccountId',
            ProgrammeObject__c = 'Account',
            AttendanceDisplayFieldName__c = 'Name',
            EventConfirmationDateField__c ='StartDate',
            EventNotesField__c = 'Description',
            EnrolmentDisplayName__c = 'Name',
            AttendanceBooleanField__c = 'Attended__c',
            ExplicitlyMarkBooleanAbsence__c = true
        );
        return IB_RegisterServerController.setting;
    }

    private static List<IB_RegisterField__mdt> createSettingFields(){
        IB_RegisterServerController.fields =  new List<IB_RegisterField__mdt>{
            new IB_RegisterField__mdt(
                FieldName__c = 'RegisterUpdated__c',
                HardcodedValue__c = 'TODAY',
                Editable__c = true
            ),
            new IB_RegisterField__mdt(
                FieldName__c = 'RegisterUpdated__c',
                HardcodedValue__c = '20200101',
                Editable__c = true
            )
        };
        return IB_RegisterServerController.fields;
    }
}