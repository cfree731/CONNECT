<%-- 
    Document   : Audit Log services
    Created on : May 5, 2008, 7:59:17 AM
    Author     : Admin
--%>

<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://java.sun.com/jstl/core" prefix="c" %>

<%@ page import="com.sun.mdm.index.edm.presentation.security.Operations"%>
<%@ page import="com.sun.mdm.index.edm.services.masterController.MasterControllerService" %>
<%@ page import="com.sun.mdm.index.edm.presentation.handlers.NavigationHandler"  %>
<%@ page import="com.sun.mdm.index.edm.services.configuration.FieldConfig"  %>
<%@ page import="com.sun.mdm.index.edm.services.configuration.ScreenObject"  %>
<%@ page import="com.sun.mdm.index.edm.services.configuration.ValidationService"  %>
<%@ page import="com.sun.mdm.index.edm.presentation.validations.EDMValidation"  %>
<%@ page import="com.sun.mdm.index.master.search.transaction.TransactionIterator" %>
<%@ page import="com.sun.mdm.index.master.search.transaction.TransactionSearchObject"%>
<%@ page import="com.sun.mdm.index.master.search.transaction.TransactionSummary"  %>
<%@ page import="com.sun.mdm.index.edm.presentation.handlers.TransactionHandler"  %>
<%@ page import="java.text.SimpleDateFormat"  %>
<%@ page import="java.util.Date"  %>
<%@ page import="java.util.ArrayList"  %>
<%@ page import="com.sun.mdm.index.edm.presentation.handlers.LocaleHandler"  %>


<%@ page import="java.util.Enumeration"%>
<%@ page import="javax.faces.context.FacesContext" %>
<%@ page import="javax.faces.application.FacesMessage" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.Iterator"  %>
<%@ page import="java.util.HashMap"  %>
<%@ page import="java.util.TreeMap"  %>
<%@ page import="java.util.ResourceBundle"  %>
<%@ page import="java.util.ArrayList"  %>
<f:view>
<%
//set locale value
if(session!=null){
 LocaleHandler localeHandler = new LocaleHandler();
 localeHandler.setChangedLocale((String) session.getAttribute("selectedLocale"));
}
%>
 <f:loadBundle basename="#{NavigationHandler.MIDM_PROP_JSP}" var="msgs" />   

<%
String URI = request.getRequestURI();URI = URI.substring(1, URI.lastIndexOf("/"));
//remove the app name 
URI = URI.replaceAll("/ajaxservices","");
boolean isSessionActive = true;
%>

<% if(session!=null && session.isNew()) {
	isSessionActive = false;
%>
 <table>
   <tr>
     <td>
  <script>
   window.location = '/<%=URI%>/login.jsf';
  </script>
     </td>
	 </tr>
	</table>
<%}%>

<%if (isSessionActive)  {%>


<%
ScreenObject screenObject = (ScreenObject) session.getAttribute("ScreenObject");
TransactionHandler transactionHandler= new TransactionHandler();
Enumeration parameterNames = request.getParameterNames();
TreeMap transDetailsMap = new TreeMap();

//Map to hold the validation Errors
HashMap valiadtions = new HashMap();

EDMValidation edmValidation = new EDMValidation();         

//Column Definitions for YUI Datatable
StringBuffer myColumnDefs = new StringBuffer();

//Labels for YUI Datatable
ArrayList labelsList  = new ArrayList();

//Keys for YUI Datatable
ArrayList keys = new ArrayList();

//List to hold the results
ArrayList results = new ArrayList();

    ResourceBundle bundle = ResourceBundle.getBundle(NavigationHandler.MIDM_PROP, FacesContext.getCurrentInstance().getViewRoot().getLocale());

String print_text = bundle.getString("print_text");
String total_records_text = bundle.getString("total_records_text");

ArrayList fullFieldNamesList  = new ArrayList();
String previousQuery=request.getQueryString(); //added by Narahari.M on 22/08/2008 for incorporate back button

%>

<%
  boolean isValidationErrorOccured = false;
  //HashMap valiadtions = new HashMap();
   ArrayList requiredValuesArray = new ArrayList();

%>

<% //Build the request Map 
   while(parameterNames.hasMoreElements())   { 
    String attributeName = (String) parameterNames.nextElement();
    String attributeValue = (String) request.getParameter(attributeName);
       if ( !("editThisID".equalsIgnoreCase(attributeName)) && 
			!("random".equalsIgnoreCase(attributeName)) ) {
		     transactionHandler.getParametersMap().put(attributeName,attributeValue);			
      }
   } 
%>

<%
results = transactionHandler.transactionSearch();
ArrayList resultConfigArray = transactionHandler.getResultsConfigArray();
if (results != null)   {
	for (int i=0;i<resultConfigArray.size();i++)    {
       	FieldConfig fieldConfig = (FieldConfig)resultConfigArray.get(i);
		//keys.add(fieldConfig.getDisplayName());
		keys.add(fieldConfig.getName());
		labelsList.add(fieldConfig.getDisplayName());
		fullFieldNamesList.add(fieldConfig.getFullFieldName());

    }

	myColumnDefs.append("[");
    String value = new String();
	for(int ji=0;ji<keys.size();ji++) {
	    if ("EUID".equalsIgnoreCase((String)keys.toArray()[ji]))  {
	      value = "{key:" + "\"" + keys.toArray()[ji]+  "\"" + ", label: " + "\"" + labelsList.toArray()[ji]+"\"" +  ",sortable:true,resizeable:true,width:150}";
	    }  else {
	      value = "{key:" + "\"" + keys.toArray()[ji]+  "\"" + ", label: " + "\"" + labelsList.toArray()[ji]+"\"" +  ",sortable:true,resizeable:true}";
	    }
       myColumnDefs.append(value);
       if(ji != keys.size()-1) myColumnDefs.append(",");
	}
    myColumnDefs.append("]");

%>

     <table border="0" cellpadding="0" cellspacing="0"> 
         <tr>
            <td style="width:87%;text-align:right">
                         <h:outputText value="#{msgs.total_records_text}"/>&nbsp;<%=results.size()%>&nbsp;
			</td>
			<td>
				<% if (results.size() > 0){%>
                    <h:panelGrid rendered="#{Operations.transLog_Print}"  >
                        <a title="<%=print_text%>" class="button" href="javascript:void(0)" onclick="javascript:getRecordDetailsFormValues('advancedformData');openPrintWindow('/<%=URI%>/printservices/transactions.jsf?random='+rand+'&'+queryStr)"><span><%=print_text%></span></a>
					</h:panelGrid>             

				<% } %>
            </td>
         </tr>
         <tr>
         <td colspan="2">
         <% if (results != null && results.size() > 0 )   {%>
             <div id="myMarkedUpContainer" class="reportresults">
                	<table id="myTable">
                  	   <thead>
                          <tr>
                     	   <% for (int i =0;i< keys.size();i++) { %>
                               <th><nobr><%=keys.toArray()[i]%></nobr></th>
                          <%}%>
                         </tr>
                	   </thead>
                  	   <tbody>
                       <% for (int i3 = 0; i3 < results.size(); i3++) { %>
                        <tr> 
                            <%HashMap valueMap = (HashMap) results.get(i3);
                             for (int kc = 0; kc < fullFieldNamesList.size(); kc++) {
				              %>
                                   <td style="text-align:right">
								   <nobr>
						          <%  if ((screenObject.getRootObj().getName()+"."+"TransactionNumber").equalsIgnoreCase((String)fullFieldNamesList.toArray()[kc])) { 
								  transDetailsMap.put(valueMap.get((screenObject.getRootObj().getName()+"."+"TransactionNumber")),valueMap.get((screenObject.getRootObj().getName()+"."+"FunctionCode")));
								  %>

                                        <a href="transeuiddetails.jsf?transactionId=<%=valueMap.get((screenObject.getRootObj().getName()+"."+"TransactionNumber"))%>&function=<%=valueMap.get((screenObject.getRootObj().getName()+"."+"FunctionCode"))%>&previousQuery=<%=previousQuery%>&fromUrl=transactions.jsf" >										
										<%= (valueMap.get(fullFieldNamesList.toArray()[kc]) == null?"":valueMap.get(fullFieldNamesList.toArray()[kc]))  %> 
										</a>
								   <%  }  else { %>
                                        <%= (valueMap.get(fullFieldNamesList.toArray()[kc]) == null?"":valueMap.get(fullFieldNamesList.toArray()[kc]))  %> 
								   <% } %>
								   </nobr>
                                   </td>
                             <%}%>
                       </tr>
                     <%}%>
					 <%session.setAttribute("transdetails",transDetailsMap);%>
	                 </tbody>
                    </table>
                </div>
		   <% } %>
           </td>
           </tr>
       </table>

      <% if (results != null && results.size() > 0 )   {%>
		<script>
			var fieldsArray = new Array();
		</script>
			<% for(int index=0;index<keys.size();index++) {%>
					<script>
						fieldsArray[<%=index%>] = '<%=keys.toArray()[index]%>';
					</script>
			<%}%>
		<script type="text/javascript">
			var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("myTable"));
			myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
			myDataSource.responseSchema = {
				fields: fieldsArray
			};
			var myConfigs = {
				paginator : new YAHOO.widget.Paginator({
					rowsPerPage    : 10, // REQUIRED
					totalRecords   : <%=results.size()%> //, // OPTIONAL
					//template       : "{PageLinks} Show {RowsPerPageDropdown} per page"
				})     
			};
			var myColumnDefs = <%=myColumnDefs.toString().length() == 0?"\""+ "\"":myColumnDefs.toString()%>;
			var myDataTable = new YAHOO.widget.DataTable("myMarkedUpContainer", myColumnDefs, myDataSource,myConfigs);
		</script>
      <% } %>
	 <script>
		//nullify any previous error messages
		 var messages = document.getElementById("messages");
	     messages.innerHTML= "";
		 messages.style.visibility="hidden";
	 </script>

<% } else { %> <!-- End results!= null -->
    <div class="ajaxalert">
    <table>
	   <tr>
	     <td>
     <%
		  Iterator messagesIter = FacesContext.getCurrentInstance().getMessages(); 
	      StringBuffer msgs = new StringBuffer("<ul>");	
          while (messagesIter.hasNext()) {
                     FacesMessage facesMessage = (FacesMessage) messagesIter.next();
                     msgs.append("<li>");
					 msgs.append(facesMessage.getSummary());
					 msgs.append("</li>");
          }
		  msgs.append("</ul>");		  
     %>     	 

	 <script>
		 var messages = document.getElementById("messages");
	     messages.innerHTML= "<%=msgs%>";
		 messages.style.visibility="visible";
	 </script>
	   </td>
	   </tr>
	 <table>
	 </div>

<% } %>
<%} %>  <!-- Session check -->
</f:view>