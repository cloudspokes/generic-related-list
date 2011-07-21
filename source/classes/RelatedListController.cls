public with sharing class RelatedListController {

	String objectLabel;
	String objectLabelPlural;
	Boolean showNewButton;
	public ApexPages.StandardSetController ssc {get; set;}
	public List<String> fieldNames {get; set;}
	public Map<String,String> fieldAlignMap {get; set;}
	public Map<String,String> nameLabelMap {get; set;}
	transient Schema.DescribeSObjectResult objectDescribe;
	public Id deleteRecordId {get; set;}
	public String sortByField {get; set;}
	public Map<String,String> fieldSortDirectionMap {get; set;}
	
	//----Variables set from attributes defined in the component----
	public String objectName {get; set;}
	public String fieldsCSV {get; set;}
	public List<String> fieldsList {get; set;}
	public String parentFieldName {get; set;}
	public Id parentFieldId {get; set;}
	public String filter {get; set;}
	public String orderByFieldName {get; set;}
	public String sortDirection {get; set;}
	public Integer pageSize {get; set;}
	
	public List<sObject> getRecords(){
		if(ssc == null){
			//Do validation to ensure required attributes are set and attributes have correct values
			//fieldList or fieldsCSV must be defined
			Boolean validationPass = true;
			
			if(fieldsList == null && fieldsCSV == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'fieldList or fieldsCSV attribute must be defined.'));
				validationPass = false;
			}
			
			//Ensure sortDirection attribute has value of 'asc' or 'desc'
			if(sortDirection != null && sortDirection != 'asc' && sortDirection != 'desc'){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'sortDirection attribute must have value of "asc" or "desc"'));
				validationPass = false;
			}
			
			//Ensure parentFieldId is not null
			if(parentFieldId == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'parentFieldId attribute can not be null'));
				validationPass = false;				
			}

			//Proceed with returning the related list if validation passed
			if(validationPass == false){
				return null;
			}else{
				//Build the query string dynamically
				String queryString = 'SELECT ';
				
				/*If field CSV was defined use this and also add fields to the fieldNames
				List so they can be used with Visualforce dynamic binding to define coloumns*/
				if(fieldsCSV != null){
					queryString += fieldsCSV;		
					fieldNames = fieldsCSV.split(',');
				}else{
					//Add fields to fieldNames list so it can be used with VF dynamic binding to define coloumns
					fieldNames = fieldsList.clone();
					
					//Loop through list of field names in fieldList and add to query
					for(String fld : fieldsList){
						queryString += fld + ',';
					}
					
					//Remove the very last comma that was added to the end of the field selection part of the query string
					queryString = queryString.substring(0,queryString.length() - 1);
				}
			
				//add from object and parent criteria
				queryString += ' FROM ' + objectName + ' WHERE ' + parentFieldName + ' = \'' + parentFieldId + '\'';
				
				//Add any addtional filter criteria to query string if it was defined in component
				if(filter != null){
					queryString += 'AND ' + filter;				
				}
				
				//Add order by field to query if defined in component
				//If sortByField != null then user has clicked a header and sort by this field
				if(sortByField != null){
					queryString += 'order by ' + sortByField;
				}else if(orderByFieldName != null){
					queryString += 'order by ' + orderByFieldName;
				}
				
				//If sortByField != null then user has clicked a header, sort based on values stored in map
				if(sortByField != null){
					/*Use a map to store the sort direction for each field, on first click of header sort asc
					and then alternate between desc*/
					if(fieldSortDirectionMap == null){
						fieldSortDirectionMap = new Map<String,String>();					
					}
					
					String direction = '';
					
					//check to see if field has direction defined, if not or it is asc, order by asc 
					if(fieldSortDirectionMap.get(sortByField) == null || fieldSortDirectionMap.get(sortByField) == 'desc' ){
						direction = 'asc';
						fieldSortDirectionMap.put(sortByField,'asc');
					}else{
						direction = 'desc';
						fieldSortDirectionMap.put(sortByField,'desc');
					}
					
					queryString += ' ' + direction;	
				}else if(sortDirection != null){
					//Add sort direction to query if defined in component
					queryString += ' ' + sortDirection;				
				}
				
				//Add limit clause to end of the query
				queryString += ' limit ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());		
				
				//Query records and setup standard set controller for pagination
				ssc = new ApexPages.StandardSetController(Database.query(queryString));
				
				//Check to see if more than 10,000 records where return, if so display warning as standard set controller can only process 10,000 recores
				if(ssc.getCompleteResult() == false){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There were more related records than could be processed. This is a partially complete list.'));
				}
				
				//Set pagination size based on value set in component
				if(pageSize != null){
					ssc.setPageSize(pageSize);
				}		
					
				/*For the fields that will be displayed identify the field type and set styleClass for
				cell alignment. Numbers, Currency, %, etc should align right in table. put in map FieldName -> class name*/
				//Get the meta data info for the fields is the related object
				Map<String, Schema.SObjectField> fieldMap = getObjectDescribe().fields.getMap(); 
				
				//For the fields in the related list populate fieldAlignMap map with the name of the correct style class. Also populate name->label map for header display
				fieldAlignMap = new Map<String,String>();
				nameLabelMap = new Map<String,STring>();
				for(String fld : fieldNames){
					String fieldType = fieldMap.get(fld).getDescribe().getType().name();	

					if(fieldType == 'CURRENCY' || fieldType == 'DOUBLE' || fieldType == 'PERCENT' || fieldType == 'INTEGER'){
						fieldAlignMap.put(fld,'alignRight');
					}else{
						fieldAlignMap.put(fld,'alignLeft');
					}	
					
					//Add to name->label map
					String label = fieldMap.get(fld).getDescribe().getLabel();
					nameLabelMap.put(fld,label);
				}
			}
		}
		return ssc.getRecords();
	}
	
	public Boolean getShowNewButton(){
		//Display new button if user has create permission for related object
		return getObjectDescribe().isCreateable();
	}
	
	public DescribeSObjectResult getObjectDescribe(){
		/*Returns object describe for related list object. This is used in many places so we are using a dedicated method that only invokes 
		Schema describe calls once as these count against Apex limits. Because this methodo returns a DescribeSObjectResult all the get 
		methods for this object can be used directly in Visualforce: {!objectDescribe.label}*/
		if(objectDescribe == null){
			objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();	
		}
		return objectDescribe;
	}
	
	public void sortByField(){
		//Making ssc variable null will cause getRecords method to requery records based on new sort by field clicked by user
		ssc = null;
	}
	
	public void deleteRecord(){
		//Delete the selected object
		for(sObject obj : ssc.getRecords()){
			if(obj.get('Id') == deleteRecordId){
				delete obj;
				break;				
			}
		}
		
		/*There is no way to modify the collecton used in a standard set controller so we will make it null and call getRecord
		method. This will reload the set of records*/
		//Save the current page number so we can keep user on same page in the set after delete
		Integer pageNumber = ssc.getPageNumber();
		
		//Make ssc variable null and execute get method
		ssc = null;
		getRecords();
		
		/*Set the correct page number. If record deleted was a single record on the last page set the number of pages in 
		the new set will decrease by 1, need to check for this. If the total number of pages is less than than the previous 
		page number set the current page to the previous last page - 1 */
		Decimal rSize = ssc.getResultSize();
		Decimal pageSize = ssc.getPageSize();
		
		if(( rSize / pageSize).round(System.RoundingMode.UP) < pageNumber){
			ssc.setPageNumber(pageNumber - 1);
		}else{
			ssc.setPageNumber(pageNumber);
		}
	}
	
	//----------------- TEST Methods------------------------
	static testMethod void test(){
		//Insert Account
		Account acct = new Account(Name='test');
    	insert acct;
		
		//Attach opportunities to account
		List<Opportunity> opps = new List<Opportunity>();
		for(Integer i = 0; i < 5; i++){
			opps.add(new Opportunity(
				AccountId = acct.Id,
				Name = 'test ' + i,
				StageName = 'stage',
				CloseDate = system.today(),
				Amount = 5
			));
		}	
		insert opps;
		
		//Setup controller for related list
		RelatedListController controller = new RelatedListController();
		
		//Set attribute variables
		controller.objectName = 'Opportunity';
		controller.fieldsCSV = 'Id,Name,Amount,CloseDate';
		controller.parentFieldName = 'AccountId';
		controller.parentFieldId = acct.Id;
		controller.filter = 'Amount > 0';
		controller.orderByFieldName=  'Amount';
		controller.sortDirection = 'desc';
		controller.pageSize = 2;
		
		//Call method to get records
		controller.getRecords();
	
		//Assert number of opps found = 5
		system.assertEquals(controller.ssc.getResultSize(), 5);
		
		//Delete an opp
		controller.deleteRecordId = opps[0].Id;
		controller.deleteRecord();	
		
		//Assert size of opps is now 4
		system.assertEquals(controller.ssc.getResultSize(), 4);
		
		//Sort by name
		controller.sortByField = 'Name';
		controller.sortByField(); //Clears list of records
		controller.getRecords(); //requeries list of records
	}
}