<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Completed Registers</label>
    <protected>false</protected>
    <values>
        <field>AllowRecordSelection__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>AvoidSharing__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>ChildObjectName__c</field>
        <value xsi:type="xsd:string">GetFurther_Session__c</value>
    </values>
    <values>
        <field>ChildSOQLClause__c</field>
        <value xsi:type="xsd:string">RegisterSubmitted__c != null AND DateValue__c &lt;= TODAY AND Tutor__c != null</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Shows Tutors registers they have recently completed. Hosted on Tutor community.</value>
    </values>
    <values>
        <field>DisplayType__c</field>
        <value xsi:type="xsd:string">Dynamic</value>
    </values>
    <values>
        <field>ExcludeCurrentContact__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>FlowName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>LookupFieldName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>MatchingFieldName__c</field>
        <value xsi:type="xsd:string">Tutor__c</value>
    </values>
    <values>
        <field>MaximumRecordsInList__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>MaximumRecords__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>OriginMatchingFieldName__c</field>
        <value xsi:type="xsd:string">Id</value>
    </values>
    <values>
        <field>ParentMatchingFieldName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ParentObjectName__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ParentSOQLClause__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>ShowRecordsWithoutChildren__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
</CustomMetadata>
