<%@ taglib uri="http://jakarta.apache.org/jspwiki.tld" prefix="wiki" %>
<%@ page import="org.apache.wiki.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page import="org.apache.wiki.action.WikiContextFactory" %>
<%
  WikiContext c = WikiContextFactory.findContext( pageContext );
  int attCount = c.getEngine().getAttachmentManager().listAttachments(c.getPage()).size();
  String attTitle = LocaleSupport.getLocalizedMessage(pageContext, "attach.tab");
  if( attCount != 0 ) attTitle += " (" + attCount + ")";
%>
  
<wiki:TabbedSection defaultTab="editcontent">  
  <wiki:Tab id="editcontent" titleKey="edit.tab.edit" accesskey="e">
  <wiki:CheckLock mode="locked" id="lock">
    <div class="error">
      <fmt:message key="edit.locked">
        <fmt:param><c:out value="${lock.locker}" /></fmt:param>
        <fmt:param><c:out value="${lock.timeLeft}" /></fmt:param>
      </fmt:message>
    </div>
  </wiki:CheckLock>
  
  <wiki:CheckVersion mode="notlatest">
    <div class="warning">
      <fmt:message key="edit.restoring">
        <fmt:param><wiki:PageVersion/></fmt:param>
      </fmt:message>
    </div>
  </wiki:CheckVersion>
    
  <wiki:Editor/>
    
</wiki:Tab>
  
  <wiki:PageExists>  

  <wiki:Tab id="attach" title="<%= attTitle %>" accesskey="a">
    <wiki:Include page="AttachmentTab.jsp" />
  </wiki:Tab>

  <wiki:Tab id="info" titleKey="info.tab"
           url="<%=c.getURL(WikiContext.INFO, c.getPage().getName())%>"
           accesskey="i" >
  </wiki:Tab>

  </wiki:PageExists>  
    
  <wiki:Tab id="edithelp" titleKey="edit.tab.help" accesskey="h">
  <wiki:InsertPage page="EditPageHelp" />
  <wiki:NoSuchPage page="EditPageHelp">
    <div class="error">
      <fmt:message key="comment.edithelpmissing">
        <fmt:param><wiki:EditLink page="EditPageHelp">EditPageHelp</wiki:EditLink></fmt:param>
      </fmt:message>
    </div>
  </wiki:NoSuchPage>  
  </wiki:Tab>

</wiki:TabbedSection>