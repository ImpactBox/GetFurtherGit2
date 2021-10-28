public class IB_RegisterServerController {

    public static IBRegisterSetting__mdt setting;
    public static List<IB_RegisterField__mdt> fields;
    
    @AuraEnabled
    public static String getAttendees(Id eventId){
        IBRegisterSetting__mdt setting = getSettings();
        EventWrapper event = getEvent(eventId, setting);
        List<AttendanceWrapper> attWraps = getAllWrappers(event,setting);
        return JSON.serialize(attWraps);
    }
    
    @AuraEnabled
    public static Map<String,String> getStatusOptions(){
        IBRegisterSetting__mdt setting = getSettings();
        if(setting.AttendanceStatusField__c!=null){
            Map<String,String> allOptions = new Map<String,String>();
            list<Schema.PicklistEntry> fmap = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).getDescribe().fields.getMap().get(setting.AttendanceStatusField__c).getDescribe().getPicklistValues();        
            for( Schema.PicklistEntry f : fmap){
                allOptions.put( f.getLabel(),f.getValue());
            }
            return allOptions;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String saveRecords(String wrappersString, String eventString){
        IBRegisterSetting__mdt setting = getSettings();
        List<AttendanceWrapper> wrappers =(List<AttendanceWrapper>)System.JSON.deserialize(wrappersString, List<AttendanceWrapper>.class);
        EventWrapper eventWrapper = (EventWrapper)System.JSON.deserialize(eventString, EventWrapper.class);
        sObject event = eventWrapper.event;
        List<sObject> attRecsToCreate = new List<sObject>();
        List<sObject> attRecsToUpdate = new List<sObject>();
        
        for(AttendanceWrapper attWrap: wrappers){
            if(setting.AttendanceStatusField__c!=null){
                attWrap.attRec.put(setting.AttendanceStatusField__c,attWrap.status);
            }
            attWrap.attRec = assginHardcodedValues(setting.AttendanceObject__c, setting.RegisterFields__r, attWrap.attRec);
            if(attWrap.fieldMap!=null){
                for(String fieldName :attWrap.fieldMap.keySet()){
                    attWrap.attRec.put(fieldName,attWrap.fieldMap.get(fieldName));    
                }
            }
            if(setting.AttendanceBooleanField__c!=null){
                if(setting.ExplicitlyMarkBooleanAbsence__c){
                    if(attWrap.statusBoolean){
                        attWrap.attRec.put(setting.AttendanceBooleanField__c,true);
                        if(attWrap.attRec.Id==null){
                            attRecsToCreate.add(attWrap.attRec);
                        }else{
                            attRecsToUpdate.add(attWrap.attRec);
                        }
                    }else if(attWrap.absentBoolean){
                        attWrap.attRec.put(setting.AttendanceBooleanField__c,false);
                        if(attWrap.attRec.Id==null){
                            attRecsToCreate.add(attWrap.attRec);
                        }else{
                            attRecsToUpdate.add(attWrap.attRec);
                        }
                    }
                } else{
                    attWrap.attRec.put(setting.AttendanceBooleanField__c,attWrap.statusBoolean);
                    if(attWrap.attRec.Id==null){
                        attRecsToCreate.add(attWrap.attRec);
                    }else{
                        attRecsToUpdate.add(attWrap.attRec);
                    }
                }
            }else{
                if(attWrap.attRec.Id==null){
                    attRecsToCreate.add(attWrap.attRec);
                }else{
                    attRecsToUpdate.add(attWrap.attRec);
                }
            }
        }
        if(setting.EventConfirmationDateField__c!=null||setting.EventNotesField__c!=null){
            saveEvent(setting, event, eventWrapper);
        }
        update attRecsToUpdate;        
        insert attRecsToCreate;
        if(wrappers.size()>0){
             return getAttendees((String)wrappers[0].attRec.get(setting.AttendanceEventLookupField__c));
        }else{
            return null;
        }
    }

    public static sObject saveEvent(IBRegisterSetting__mdt setting, sObject event, EventWrapper eventWrapper){
        if(setting.EventConfirmationDateField__c!=null){
            event.put(setting.EventConfirmationDateField__c,system.today());
        }
        if(setting.EventNotesField__c!=null){
            event.put(setting.EventNotesField__c,eventWrapper.notes);
        }
        update event;
        return event;
    }
    
    @AuraEnabled
    public static IBRegisterSetting__mdt getSettings(){
        try{
            List<IBRegisterSetting__mdt> settings = [SELECT Id , EnrolmentObject__c, ProgrammeObject__c, EnrolmentProgrammeLookupField__c, 
            EventObject__c, EventProgrammeLookupField__c, EventDateField__c, EventDateTimeField__c, EventTimeField__c,
            AttendanceEnrolmentLookupField__c, AttendanceEventLookupField__c, AttendanceObject__c, AttendanceStatusField__c, 
            EnrolmentDisplayName__c, AttendanceBooleanField__c, EventTitleField__c, EnrolmentSortField__c,  
            EnrolmentSortOrder__c, EventConfirmationDateField__c, ExplicitlyMarkBooleanAbsence__c, AttendanceDisplayFieldName__c,
            EnrolmentSOQLWhereClause__c, AttendanceSOQLWHEREClause__c, EventNotesField__c, EventNotesHelpText__c,
            (SELECT ID, FieldName__c, HardcodedValue__c, Editable__c, DependentField__c, DependentFieldValues__c FROM RegisterFields__r)
            FROM IBRegisterSetting__mdt];
            if(settings!=null){
                return settings[0];
            }else{
                return IB_RegisterServerController.setting;
            }
        }catch(Exception e){
            return IB_RegisterServerController.setting;
        }
    }
    
    @AuraEnabled
    public static String getEventWrapperString(String eventId){
        return JSON.serialize(getEvent(eventId, getSettings()));        
    }

    @AuraEnabled
    public static String returnFields(String listName){
        return JSON.serialize(getFields(getSettings()));
    }

    public static List<FieldWrap> getFields(IBRegisterSetting__mdt setting) {
        Map<String, List<IB_RegisterField__mdt>> fields = getSettingFields();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).getDescribe().fields.getMap();  
        List<FieldWrap> allFields = new List<FieldWrap>();
        if(fields!=null&&!fields.isEmpty()){
            for(IB_RegisterField__mdt f: fields.get(setting.Id)){
                Schema.SObjectField sField = fieldMap.get(f.FieldName__c);
                allFields.add(constructWrapper(sField, f));
            }
        }
        
        return allFields;
    }

    public static Map<String, List<IB_RegisterField__mdt>> getSettingFields(){
        Map<String, List<IB_RegisterField__mdt>> fields = new Map<String, List<IB_RegisterField__mdt>>();
        List<IB_RegisterField__mdt> fieldsList = test.isRunningTest()? 
                IB_RegisterServerController.fields:
                [SELECT ID, FieldName__c, HardcodedValue__c, Editable__c, IBRegister__c, 
                        DependentField__c, DependentFieldValues__c, DependencyErrorMessage__c, OrderNumber__c FROM IB_RegisterField__mdt ORDER BY OrderNumber__c];
        for(IB_RegisterField__mdt field : fieldsList){
            List<IB_RegisterField__mdt> settingFields = fields.get(field.IBRegister__c);
            if(settingFields==null){
                settingFields = new List<IB_RegisterField__mdt>();
            }
            settingFields.add(field);
            fields.put(field.IBRegister__c,settingFields);
        }
        return fields;
    }

    public static sObject assginHardcodedValues(String objName, List<IB_RegisterField__mdt> fields, sObject rec){
        fields = fields==null||fields.size()==0? IB_RegisterServerController.fields:fields;
        if(fields!=null&&fields.size()>0){
            for(IB_RegisterField__mdt field: fields){
                if(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field.FieldName__c).getDescribe().getSOAPType()==SoapType.DATE){
                    if(field.HardcodedValue__c=='TODAY'||field.HardcodedValue__c=='Today'){
                        rec.put(field.FieldName__c,system.today());
                    }else{
                        Date dateValue = Date.valueOf(field.HardcodedValue__c.left(4)+'-'+field.HardcodedValue__c.right(4).left(2)+'-'+field.HardcodedValue__c.right(2));
                        rec.put(field.FieldName__c,dateValue);
                    }
                }else if(Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(field.FieldName__c).getDescribe().getSOAPType()==SoapType.DOUBLE){
                    rec.put(field.FieldName__c,decimal.valueOf(field.HardcodedValue__c));
                }else{
                    rec.put(field.FieldName__c,(String)field.HardcodedValue__c);
                }
            }
        }
        return rec;
    }
    
    public static EventWrapper getEvent(String eventId, IBRegisterSetting__mdt setting){        
        sObject event = database.query(buildEventQuery(eventId,setting));
        EventWrapper eventWrap = new EventWrapper();
        eventWrap.eventID = (String)event.get('Id');
        eventWrap.event = event;
        if(setting.EventProgrammeLookupField__c!=null){
            eventWrap.programmeId = (String)event.get(setting.EventProgrammeLookupField__c);    
        }
        if(setting.EventTitleField__c!=null){
            eventWrap.name = (String)event.get(setting.EventTitleField__c);            
        }
        if(setting.EventDateField__c!=null){
            eventWrap.eventDate = (Date)event.get(setting.EventDateField__c);            
        }
        if(setting.EventDateTimeField__c!=null){
            eventWrap.eventDateTime = (Datetime)event.get(setting.EventDateTimeField__c);            
        }
        if(setting.EventTimeField__c!=null){
            eventWrap.eventTime = (Time)event.get(setting.EventTimeField__c);            
        }
        if(setting.EventNotesField__c!=null){
            eventWrap.notes = (String)event.get(setting.EventNotesField__c);            
        }
        return eventWrap;
    }
    
    public static String buildEventQuery(String eventId, IBRegisterSetting__mdt setting){
        String query = 'SELECT Name, Id';
        if(setting.EventProgrammeLookupField__c!=null){
            query = query+', '+setting.EventProgrammeLookupField__c;
        }
        if(!query.contains(setting.EventTitleField__c)){
             query = query+', '+setting.EventTitleField__c;
        }
        if(setting.EventDateField__c !=null){
            query = query+', '+setting.EventDateField__c;
        }
        if(setting.EventDateTimeField__c !=null){
            query = query+', '+setting.EventDateTimeField__c;
        }
        if(setting.EventTimeField__c !=null){
            query = query+', '+setting.EventTimeField__c;
        }
        if(setting.EventNotesField__c !=null){
            query = query+', '+setting.EventNotesField__c;
        }
        query = query+' FROM '+setting.EventObject__c+' WHERE Id = \''+eventId+'\'' ;
        return query;
    }
    
    public static List<AttendanceWrapper> getAllWrappers(EventWrapper event, IBRegisterSetting__mdt setting){
        Map<String, sObject> enrols= new Map<String, sObject>();
        if(setting.EnrolmentObject__c!=null&&event.programmeId!=null){
            enrols = getEnrolments(event.programmeId, setting);
        }
        List<AttendanceWrapper> wraps = getExistingAttendanceWrappers(setting, event, enrols);
        Map<String, AttendanceWrapper> wrapsMAp = new Map<String, AttendanceWrapper>();
        
        Set<String> existingAttIds = new Set<String>();
        for(AttendanceWrapper wrap: wraps){
            existingAttIds.add((String)wrap.enrolmentId);
        }
        if(enrols!=null){
            for(sObject rec:enrols.values()){
                if(!existingAttIds.contains(rec.Id)){
                    AttendanceWrapper wrap = new AttendanceWrapper();
                    sObject att = Schema.getGlobalDescribe().get(setting.AttendanceObject__c).newSObject();
                    att.put(setting.AttendanceEventLookupField__c, event.eventId);
                    att.put(setting.AttendanceEnrolmentLookupField__c, rec.Id);
                    wrap.attRec = att;
                    wrap.name = (String)rec.get(setting.EnrolmentDisplayName__c );
                    wrap.enrolmentId =rec.Id;
                    wrap.statusBoolean = false;
                    wrap.absentBoolean = false;
                    wraps.add(wrap);
                }
            }
        }
        
        return wraps;
    }
    
    public static Map<String, sObject> getEnrolments(String programmeId,IBRegisterSetting__mdt setting){
        String query = 'SELECT Id, '+setting.EnrolmentProgrammeLookupField__c  +', '+setting.EnrolmentDisplayName__c+' FROM '+setting.EnrolmentObject__c+' WHERE '+setting.EnrolmentProgrammeLookupField__c +' = \''+programmeId+'\'' ;
        if(setting.EnrolmentSOQLWHEREClause__c!=null){
            query = query +' AND '+setting.EnrolmentSOQLWHEREClause__c;
        }
        
        if(setting.EnrolmentSortField__c!=null){
            query = query + ' ORDER BY '+setting.EnrolmentSortField__c;
            if(setting.EnrolmentSortOrder__c!=null){
                query = query + ' '+setting.EnrolmentSortOrder__c;
            }
        }
        return new Map<String, sObject>(database.query(query));
    }    
    
    public static List<AttendanceWrapper> getExistingAttendanceWrappers(IBRegisterSetting__mdt setting, EventWrapper event, Map<String, sObject> enrols){
        List<AttendanceWrapper> wraps = new List<AttendanceWrapper>();
        String query = 'SELECT '+setting.AttendanceEventLookupField__c;
        if(setting.AttendanceDisplayFieldName__c!=null){
            query = query +', '+setting.AttendanceDisplayFieldName__c;
        }        
        if(setting.AttendanceEnrolmentLookupField__c!=null){
            query = query +', '+setting.AttendanceEnrolmentLookupField__c;
        }        
        if(setting.AttendanceBooleanField__c!=null){
            query = query +', '+setting.AttendanceBooleanField__c;
        }
        if(setting.AttendanceStatusField__c!=null){
            query = query +', '+setting.AttendanceStatusField__c;
        }
        if(setting.RegisterFields__r!=null&&setting.RegisterFields__r.size()>0){
            for(IB_RegisterField__mdt field: setting.RegisterFields__r){
                if(!query.contains(field.FieldName__c)){
                    query = query+', '+field.FieldName__c;
                }
            }
        }
        query = query +' FROM '+setting.AttendanceObject__c +' WHERE '+setting.AttendanceEventLookupField__c+' = \''+event.eventId+'\' ' ;
        if(setting.AttendanceSOQLWHEREClause__c!=null){
            query = query +' AND '+setting.AttendanceSOQLWHEREClause__c;
        }
        List<sObject> records = database.query(query);
        for(sObject rec: records){
            AttendanceWrapper wrap = new AttendanceWrapper();
            wrap.attRec = rec;
            if(enrols!=null&&enrols.get((String)rec.get(setting.AttendanceEnrolmentLookupField__c))!=null){
                wrap.name = (String)enrols.get((String)rec.get(setting.AttendanceEnrolmentLookupField__c)).get(setting.EnrolmentDisplayName__c);
            }else{
                // add attendance name function*********************************
                wrap.name = (String)rec.get(setting.AttendanceDisplayFieldName__c);
            }
            if(setting.AttendanceEnrolmentLookupField__c!=null){
                wrap.enrolmentId = (String)rec.get(setting.AttendanceEnrolmentLookupField__c);
            }
            if(setting.AttendanceStatusField__c!=null){
                wrap.status = (String)rec.get(setting.AttendanceStatusField__c);
            }
            if(setting.AttendanceBooleanField__c!=null){
                wrap.statusBoolean = (Boolean)rec.get(setting.AttendanceBooleanField__c );
                wrap.absentBoolean = !(Boolean)rec.get(setting.AttendanceBooleanField__c );
            }
            wraps.add(wrap);
        }
        return wraps;
    }    

    public static FieldWrap constructWrapper(Schema.SObjectField f, IB_RegisterField__mdt field){
        FieldWrap wrap = new FieldWrap();
        wrap.label = f.getDescribe().getLabel();
        wrap.value = f.getDescribe().getName();
        wrap.type = f.getDescribe().getType();
        wrap.editable = field.Editable__c;
        wrap.dependentField = field.DependentField__c;
        wrap.dependentFieldValues = field.DependentFieldValues__c;
        wrap.errorMessage = field.DependencyErrorMessage__c;
        if(wrap.type==Schema.DisplayType.PICKLIST||wrap.type==Schema.DisplayType.MULTIPICKLIST){
            List<PVal> pValues = new List<PVal>();
            for(Schema.PicklistEntry plOption: f.getDescribe().getPicklistValues()){
                PVal val = new PVal();
                val.value = plOption.getValue();
                val.label = plOption.getLabel();
                pValues.add(val);
            }
            wrap.pVals = pValues;
        }
        return wrap;
    }
    
    public class AttendanceWrapper{
        public sObject attRec{get; set;}
        public Contact contact{get; set;}
        public String name {get; set;}
        public boolean selected {get; set;}
        public Id enrolmentId {get; set;}
        public String status {get; set;}
        public Boolean statusBoolean {get; set;}        
        public Boolean absentBoolean {get; set;} 
        public Map<String,String> fieldMap{get; set;}      
    }
    
    public class EventWrapper{
        public date eventDate {get; set;}
        public datetime eventDateTime {get; set;}
        public time eventTime {get; set;}
        public String name {get; set;}
        public String eventId {get; set;}
        public String programmeId {get; set;}
        public String notes {get; set;}
        public sObject event {get; set;}
    }

    public class FieldWrap{
        public String label;
        public String value;
        public Schema.DisplayType type;
        public Boolean editable;
        public Boolean button;
        public String dependentField;
        public String dependentFieldValues;
        public String errorMessage;
        public List<PVal> pVals;
    }

    public class PVal{
        public String label;
        public String value;
        public String selected;
    }
}