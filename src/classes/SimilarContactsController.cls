public with sharing class SimilarContactsController {
    public String 	clickedContactId 	{get;set;}
    public List<contactWrapper> wrappedContacts = new List<contactWrapper>();
    
    public PageReference setSelectedContact() {
        PageReference pageRef = Page.ShowContact;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('clickedContactId', clickedContactId);
        System.debug('setSelectedContact' + clickedContactId);
        return pageRef;
    }
    
    public void mergeContacts() {
        System.debug('mergeContacts');
        String mainContactID=ApexPages.currentPage().getParameters().get('contactsIdForMerge');
        System.debug(mainContactID);
        List<String> ListIdForMerge = mainContactID.split(', ');
        if(ListIdForMerge.size() == 2) {
            Contact mainContact = [SELECT Id FROM Contact WHERE Id =: ListIdForMerge[0]];
            Contact mergeContact = [SELECT Id FROM Contact WHERE Id =: ListIdForMerge[1]];
            try {
                merge mainContact mergeContact;
                System.debug('was merged');
            } catch (DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
        }
        System.debug('done');
    }
    
    public void deleteContact() {
        System.debug('deleteContact');
        String delContactID = ApexPages.currentPage().getParameters().get('contactsIdForDelete');
        System.debug(delContactID);
        if(string.isNotEmpty(delContactID)) {
            try {
                Contact deleteContact = [SELECT Id FROM Contact WHERE Id =: delContactID];
        		delete deleteContact;
                System.debug('was deleted');
            } catch (DmlException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage());
            }
        }
        System.debug('done');
    }
    
	public SimilarContactsController() {
        Integer i = 1;
        List<Contact> mainList = new List<Contact>([SELECT FirstName, LastName, Email
                                                    FROM Contact
                                                    ORDER BY FirstName ASC]);
        for (Contact mainContact : mainList) {
            for (Contact dublicateContact : mainList) {
                if(mainContact.FirstName == dublicateContact.FirstName 
                   && mainContact.LastName == dublicateContact.LastName 
                   && mainContact.Id != dublicateContact.Id) {
                       if(mainContact.Email == dublicateContact.Email) {
                           contactWrapper wrappedContact = new contactWrapper(i, mainContact, dublicateContact, dublicateContact);
                           wrappedContacts.add(wrappedContact);
                           i++;
                       } else {
                           contactWrapper wrappedContact = new contactWrapper(i, mainContact, dublicateContact, null);
                           wrappedContacts.add(wrappedContact);
                           i++;
                       }
                }
            }
        }
        
	}
	
	public List<contactWrapper> getWrappedContacts() {
        if(!wrappedContacts.isEmpty()) {
            return wrappedContacts;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'there are no similar contacts'));
            return null;
        }
        
	}
	
	public class contactWrapper {
        
        public Integer contactCounter {get; set;} 
        public Contact mainContact {get; set;}
        public Contact possibleContact {get; set;}
        public Contact explicitContact {get; set;}
        
		public contactWrapper(Integer passedInteger, Contact passedMainContact, Contact passedPossibleContact, Contact passedExplicitContact) {
            contactCounter = passedInteger;
            mainContact = passedMainContact;
            possibleContact = passedPossibleContact;
            explicitContact = passedExplicitContact;
        }
    }
}