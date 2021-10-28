({
    doInit : function(cmp, event, helper) {
        helper.getfields(cmp, event, helper);        
        helper.getRegisterOptions(cmp, event, helper);        
        helper.getEventDetails(cmp, event, helper);        
        helper.getStatusOptions(cmp, event, helper);        
    },

    refresh : function(cmp, event, helper) {
        helper.getAttRecords(cmp, event, helper);
    },

    save : function(cmp, event, helper) {
        console.log('Save')
        helper.helperSave(cmp, event, helper);
    },

    addRecord : function(cmp, event, helper) {
        console.log("addRecord")
        var registerOptions = cmp.get("v.registerOptions")
        var event = cmp.get("v.event")
        var dfvMAp = new Map();
        dfvMAp[registerOptions.EnrolmentProgrammeLookupField__c] = event.programmeId

        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": registerOptions.EnrolmentObject__c,
            "defaultFieldValues": dfvMAp,
            "navigationLocation": "RELATED_LIST"
        });
    	createRecordEvent.fire();
    },
    
})