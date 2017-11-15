/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.eperson.openid;

import org.dspace.app.xmlui.aspect.eperson.*;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.http.HttpEnvironment;
import org.apache.cocoon.sitemap.PatternException;
import org.dspace.app.xmlui.utils.AuthenticationUtil;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.Group;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.EPersonService;
import org.dspace.eperson.service.GroupService;

/**
 * Attempt to authenticate the user based upon their presented credentials. 
 * This action uses the HTTP parameters of login_email, login_password, and
 * login_realm as credentials.
 * 
 * <p>If the authentication attempt is successful then an HTTP redirect will be
 * sent to the browser redirecting them to their original location in the 
 * system before authenticated or if none is supplied back to the DSpace 
 * home page. The action will also return true, thus contents of the action will
 * be executed.
 *
 * <p>If the authentication attempt fails, the action returns false.
 *
 * <p>Example use:
 *
 * <pre>
 * {@code
 * <map:act name="Authenticate">
 *   <map:serialize type="xml"/>
 * </map:act>
 * <map:transform type="try-to-login-again-transformer">
 * }
 * </pre>
 *
 * @author Scott Phillips
 */
public class AdduserAction extends AbstractAction
{
    
    protected EPersonService ePersonService = EPersonServiceFactory.getInstance().getEPersonService();
    protected GroupService groupService = EPersonServiceFactory.getInstance().getGroupService();
    /**
     * Attempt to authenticate the user. 
     * @param redirector redirector.
     * @param resolver source resolver.
     * @param objectModel object model.
     * @param source source
     * @param parameters sitemap parameters.
     * @return result of the action.
     * @throws java.lang.Exception on error.
     */
    @Override
    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel,
            String source, Parameters parameters) throws Exception
    {
        // First check if we are performing a new login
        Request request = ObjectModelHelper.getRequest(objectModel);

        String rut = request.getParameter("register_rut");
        String name = request.getParameter("register_name");
        String lastname = request.getParameter("register_lastname");
        String password = request.getParameter("login_password");
        String realm = request.getParameter("login_realm");

        // Protect against NPE errors inside the authentication
        // class.
        if ((rut == null) || (password == null) || (name == null) || (lastname == null))
		{
			return null;
		} else {
        
        Context context = AuthenticationUtil.authenticate(objectModel, rut,password, realm); 
       EPerson eperson = null;
       context.turnOffAuthorisationSystem();
       eperson = ePersonService.findByEmail(context, rut);
        
        Group admins = groupService.findByName(context, Group.ADMIN);
                       
                        
                        if (eperson == null)
                        {
                            eperson = ePersonService.create(context);
                            eperson.setEmail(rut);
                            eperson.setCanLogIn(true);
                            eperson.setRequireCertificate(false);
                            eperson.setSelfRegistered(false);
                        }
                        
                        eperson.setLastName(context, lastname); 
                        eperson.setFirstName(context, name);
                        eperson.setLanguage(context, "es_ES");
                        ePersonService.setPassword(eperson, password);
                        ePersonService.update(context, eperson);

                        groupService.addMember(context, admins, eperson);
                        groupService.update(context, admins);

                        context.complete();
        } 
        
        return null;
    }

}
