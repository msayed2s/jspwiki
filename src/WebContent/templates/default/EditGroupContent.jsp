<%@ taglib uri="http://jakarta.apache.org/jspwiki.tld" prefix="wiki" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ page import="java.security.Principal" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="org.apache.wiki.auth.PrincipalComparator" %>
<%@ page import="org.apache.wiki.auth.authorize.Group" %>
<%@ page import="org.apache.wiki.*" %>
<%@ page import="org.apache.wiki.log.Logger" %>
<%@ page import="org.apache.wiki.log.LoggerFactory" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.*" %>
<%@ page errorPage="/Error.jsp" %>
<%@ taglib uri="http://stripes.sourceforge.net/stripes.tld" prefix="stripes" %>
<%@ page import="org.apache.wiki.action.WikiContextFactory" %>
<%@ page import="org.apache.wiki.util.TextUtil" %>
<%!
    Logger log = LoggerFactory.getLogger("JSPWiki");
%>

<%
  WikiContext c = WikiContextFactory.findContext( pageContext );

  // Extract the group name and members
  String name = request.getParameter( "group" );
  Group group = (Group)pageContext.getAttribute( "Group",PageContext.REQUEST_SCOPE );
  Principal[] members = null;

  if ( group != null )
  {
    name = group.getName();
    members = group.members();
    Arrays.sort( members, new PrincipalComparator() );
  }
  name = TextUtil.replaceEntities(name);
%>

<wiki:TabbedSection defaultTab="editgroup">

  <wiki:Permission permission="viewGroup">
  <wiki:Tab id="viewgroup" titleKey="actions.viewgroup"
           url='<%=c.getURL(WikiContext.NONE, "Group.jsp", "group="+request.getParameter("group") ) %>'
           accesskey="v" >
  </wiki:Tab>
  </wiki:Permission>

  <wiki:Tab id="editgroup" titleKey="editgroup.tab">

  <h3><%=name%></h3>

  <form action="<wiki:Link format='url' jsp='EditGroup.jsp'/>"
         class="wikiform"
            id="editGroup"
        method="POST" accept-charset="UTF-8">

    <!-- Members -->
    <%
      StringBuffer s = new StringBuffer();
      for ( int i = 0; i < members.length; i++ )
      {
        s.append( members[i].getName().trim() );
        s.append( '\n' );
      }
    %>
    <div class="formhelp">
    <fmt:message key="editgroup.instructions">
      <fmt:param><%=name%></fmt:param>
     </fmt:message>
    </div>
    <div class="formhelp">
      <wiki:Messages div="error" topic="group" prefix='<%=LocaleSupport.getLocalizedMessage(pageContext,"editgroup.saveerror") %>' />
    </div>

    <table class="wikitable">
    <tr>
      <th><fmt:message key="group.name" /></th>
      <td><%=name%></td>
    </tr>
    <tr>
      <th><label><fmt:message key="group.members" /></label></th>
      <td>
      <textarea id="members" name="members" rows="10" cols="30"><%=TextUtil.replaceEntities(s.toString())%></textarea>
      <div class="formhelp"><fmt:message key="editgroup.memberlist" /></div>
      </td>
    </tr>
    </table>
    <div class="formhelp">
      <fmt:message key="editgroup.savehelp"><fmt:param><%=name%></fmt:param></fmt:message>
    </div>
      <input type="submit" name="ok" value="<fmt:message key="editgroup.submit.save" />" />
      <input type="hidden" name="group" value="<%=name%>" />
      <input type="hidden" name="action" value="save" />
  </form>

  <wiki:Permission permission="deleteGroup"> 
  <form action="<wiki:Link format='url' jsp='DeleteGroup.jsp'/>"
         class="wikiform"
            id="deleteGroup"
        onsubmit="return( confirm('<fmt:message key="grp.deletegroup.confirm"/>') 
        && Wiki.submitOnce(this) );"
        method="POST" accept-charset="UTF-8">
      <input type="submit" name="ok" value="<fmt:message key="actions.deletegroup"/>" />
      <input type="hidden" name="group" value="${param.group}" />
  </form>
  </wiki:Permission>

</wiki:Tab>

</wiki:TabbedSection>