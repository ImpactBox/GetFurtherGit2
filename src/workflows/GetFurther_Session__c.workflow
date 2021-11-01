<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Tutor_Register_Reminder_Email_Alert</fullName>
        <description>Tutor Register Reminder Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Tutor__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Session_Register_Reminder_Email_Tutors_1634551435993</template>
    </alerts>
    <alerts>
        <fullName>Tutor_Register_Reminder_Email_Alert_24_Hours</fullName>
        <description>Tutor Register Reminder Email Alert 24 Hours</description>
        <protected>false</protected>
        <recipients>
            <field>Tutor__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Session_Register_Reminder_Email_24_Hours_1635706689115</template>
    </alerts>
</Workflow>
