public with sharing class RelatedListDemoController {
    
    public Opportunity opp {get; set;}
    
    public RelatedListDemoController(ApexPages.StandardController controller) {
        opp = new Opportunity();
    }

    public PageReference loadList(){
        PageReference newPage = Page.relatedListDemo;
        newPage.getParameters().put('id',opp.AccountId);
        newPage.setRedirect(true);
        return newPage;
    }
    
    //--------------------TEST Method--------------------
    static testMethod void test(){
    	//Insert an account
    	Account acct = new Account(Name='test');
    	insert acct;
    	
    	//Setup standard controller
    	ApexPages.StandardController sc = new ApexPages.StandardController(acct);
    	
    	Test.startTest();
		RelatedListDemoController controller = new RelatedListDemoController(sc);
    	controller.opp.AccountId = acct.Id;
    	system.assert(controller.LoadList().getURL().contains(acct.Id));
    	Test.stopTest();
    }      
}