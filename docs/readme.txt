CloudSpokes Related List Challenge

Package install link: https://login.salesforce.com/?startURL=%2Fpackaging%2FinstallPackage.apexp%3Fp0%3D04tE0000000HD7N
Sites Demo link: http://tehnrd-cs-developer-edition.na9.force.com/relatedListDemo?id=001E0000002N9dn

Package contains an app with one tab that allows you to enter an account name and demo the related list functionality.

Highlighted features:
- Related list is fully dynamic, header values, field formatting, styling, translation of header labels, etc.
- Pagination provides first, previous, next, last functionality
- Pagination allows user to jump to specific  page in set
- Includes Edit and Del action links
- New Button is only displayed if user has create permission on related object

Notes:
I believe this meets of the challenge requirements except one, collection of field meta data that lists field name, sortable, direction, order. Most of these challenges  have been open to interpretation and I know I'm taking a risk deviating from the requirements but here is what I did differently.

- For starters all columns are sortable. Only allowing some columns to be sortable would be inconsistent standard functionality and could confuse users. Making all columns sortable also reduces the amount of code required. The only reason I can think of that a column should not be sortable is if you want to "hide" information. For example you don't want users to easily identify large opportunities (material info). The problem with this is that a user could run a separate  report to get this information anyway. In the end I just feel there are more pros to making all columns sortable than cons. 

- To define the columns in the field I am giving the user of the component options. They can either provide a comma separated string of field names or a List of field names for the table.

These where the only two variances from the requirements. As mentioned before, deviated from requirements was a risk, but I think it improves this component and the changes make it easier to use from a developer perspective.

Attributes:

Below is a list of valid attributes for this component.

fieldsCSV		Comma separated list of API field names that will be displayed in the relatedList. If defined, this will override the fieldsList attribute.			
fieldsList		List collection variable containing the API field names that will be displayed in the related list.			
filter			Additional filter criteria applied to the objects returned. This shoud not start with 'where' keyworld, simply 'Active = true AND ...'.				
hideActionLinks		If set to true this will hide the Action links in the first column.			
hideButtons		Hide the New button, button will only be displayed if current user has create permission on this object.		
id			An identifier that allows the component to be referenced by other components in the page.			
objectName		The API name of the object representing this relatedList	
orderByFieldName	List of recoreds will be ordered by this field on initial load of the releated list.		
pageSize		Sets the number of records in each page set.			
parentFieldId		The 15 or 18 digit Id of the parent record for this related list.	
parentFieldName		The API name of the relationship field for the related list. For example: AccountId on Opportunity object.	
rendered		A Boolean value that specifies whether the component is rendered on the page. If not specified, this value defaults to true.			
sortDirection		Initial sort order of the related list on load. Valid values are 'asc' and 'desc'.		
urlForNewRecord		Please define the URL for new record creation. For example: '#{URLFOR($Action.Opportunity.New,null)}'.	