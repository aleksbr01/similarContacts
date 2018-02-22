public class ContactDetails {
    public Contact 	clickedContact 		{get;set;}
    public ContactDetails() {
        String selectedContactId = ApexPages.currentPage().getParameters().get('clickedContactId');
        String queryString = 'SELECT Id';
        for(Schema.FieldSetMember fld : SObjectType.Contact.FieldSets.contactFieldSet.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }
        queryString += ' FROM Contact WHERE Id = :selectedContactId';
        clickedContact = Database.query(queryString);
    }

}