({

    getfields : function(cmp, event, helper) {
		console.log("getfields")
		var listName = cmp.get('v.listName');
			
		var action = cmp.get("c.returnFields");
		action.setParams({
			listName: listName
		});         
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set("v.fields", JSON.parse(response.getReturnValue()));
                this.getAttRecords(cmp, event, helper)
			}
			else {
				console.log("Failed to get fields");
			}
		});
		$A.enqueueAction(action);

    },
    
    getAttRecords : function(cmp, event, helper){
        var recordId = cmp.get('v.recordId');
        var fields = cmp.get('v.fields');
        if(recordId!=null){
            var action = cmp.get("c.getAttendees");
            action.setParams({eventId: recordId});         
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.wrappers", this.createListFromApex(JSON.parse(response.getReturnValue()),fields))
                    //cmp.set("v.wrappers", JSON.parse(response.getReturnValue()));
                    cmp.set("v.loading",false)
                }
                else {
                    console.log("Failed to get attendees");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    getStatusOptions : function(cmp, event, helper){
        console.log("getStatusOptions")
        var action = cmp.get("c.getStatusOptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var setOptions = [];
                var options = response.getReturnValue();
                for(var opt in options){
                    setOptions.push({value:options[opt], opt:opt})
                }
                cmp.set("v.statusOptions", setOptions);
                //helper.getAttRecords(cmp, event, helper)
            }
            else {
                console.log("Failed to get options");
            }
        });
        $A.enqueueAction(action);
    },
    
    getRegisterOptions : function(cmp, event, helper){
        var recordID = cmp.get('v.recordId');
        if(recordID!=null){
            var action = cmp.get("c.getSettings");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.registerOptions", response.getReturnValue());
                }
                else {
                    console.log("Failed to get register options");
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    getEventDetails : function(cmp, event, helper){
        var recordID = cmp.get('v.recordId');
        if(recordID!=null){
            var action = cmp.get("c.getEventWrapperString");
            action.setParams({eventId: recordID});         
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.event", JSON.parse(response.getReturnValue()));
                }
                else {
                    console.log("Failed to get event");
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    helperSave: function(cmp, event, helper){
        console.log('helperSave')
        cmp.set("v.loading",true)
        var wrappers = cmp.get('v.wrappers');
        //var wrappers = JSON.stringify(this.separateRecordsFromWrapper(wrappers));
        var fields = cmp.get('v.fields');
        var errorMessage = this.checkWrapperValidation(wrappers,fields)
        if(errorMessage===null||errorMessage===undefined||errorMessage===''){
            if(wrappers!=null){ 
                var event = JSON.stringify(cmp.get('v.event'));
                wrappers = JSON.stringify(this.separateRecordsFromWrapper(wrappers));
                var action = cmp.get("c.saveRecords");
                action.setParams({
                    wrappersString: wrappers,
                    eventString: event
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        cmp.set("v.wrappers", this.createListFromApex(JSON.parse(response.getReturnValue()),fields))
                        //cmp.set("v.wrappers", JSON.parse(response.getReturnValue()));
                        helper.fireToast(cmp, event, helper, "Records Saved!", "success")
                        cmp.set("v.loading",false)
                    }
                    else {
                        console.log("Failed to Save attendees");
                        helper.fireToast(cmp, event, helper, "Error in Save - please contact your system administrator", "error")
                        cmp.set("v.loading",false)
                    }
                });
                $A.enqueueAction(action);
            }else{
                helper.fireToast(cmp, event, helper, "Error in Save - no records found", "error")
                cmp.set("v.loading",false)
            }
        }else{
            helper.fireToast(cmp, event, helper, errorMessage,"error")
            cmp.set("v.loading",false)
        }
        
    },

    checkWrapperValidation: function(wrappers, fields){
        console.log('checkWrapperValidation')
        var failureMessage='';
        for(var wrap of wrappers){
            for(var recField of wrap.value){
                if(recField.field.dependentField!=null&&recField.field.dependentField!=undefined){

                    console.log(wrap.opt.attRec[recField.field.dependentField])
                    console.log(recField.value )
                    console.log(recField.value )

                    if(recField.field.dependentFieldValues===null||recField.field.dependentFieldValues===undefined){
                        if((wrap.opt.attRec[recField.field.dependentField]!=undefined||wrap.opt.attRec[recField.field.dependentField]!=null)
                        && (recField.value===undefined||recField.value===null)){
                            failureMessage = failureMessage + recField.field.errorMessage;
                        }
                    }else if(recField.field.dependentFieldValues!=null&&recField.field.dependentFieldValues!=undefined&&recField.field.dependentFieldValues.includes(wrap.opt.attRec[recField.field.dependentField])&&
                    (recField.value===undefined||recField.value===null)){
                        failureMessage = failureMessage + recField.field.errorMessage;
                    }
                }           
            }
        }
        console.log('failureMessage: '+failureMessage)
        return failureMessage;
    },

    separateRecordsFromWrapper: function(wrappers) {
        console.log('separateRecordsFromWrapper')
		var records = [];
		for(var wrap of wrappers){
            var rec = wrap.opt;
            var fieldMap = new Map();
			for(var field of wrap.value){
                fieldMap[field.opt] = field.value
            }
            rec.fieldMap = fieldMap;
			records.push(rec)
		}
		return records;
	},

    createListFromApex : function(recordsList,fields) {
		//console.log("createListFromApex")
		var allRecValues = [];
		for(var rec of recordsList){
            console.log(rec)
			var recVals = [];
			for(var field of fields){
                recVals.push({opt: field.value, value: rec.attRec[field.value], type:field.type, editable: field.editable, field:field, /*button:field.button,*/ pVals :field.pVals})
			}
			allRecValues.push({opt: rec, value: recVals })
		}
		return allRecValues;
	},
    
    fireToast : function(cmp, event, helper, message, status){
        var mode;
        var duration;
        if(status === 'success'){
            mode = 'pester';
            duration = 50;
        }else{
            mode = 'pester';
            duration = 100; 
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: mode,
            duration: duration,
            type: status,
            message: message,
            messageTemplate: message,
            messageTemplateData: ['Salesforce', {
                url: 'http://www.salesforce.com/',
                label: 'here',
            }]
        });
        toastEvent.fire(); 
    },
})