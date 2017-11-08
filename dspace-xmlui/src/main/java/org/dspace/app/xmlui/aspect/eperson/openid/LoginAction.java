/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.eperson.openid;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.http.HttpEnvironment;
import org.dspace.app.xmlui.utils.AuthenticationUtil;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.factory.EPersonServiceFactory;
import org.dspace.eperson.service.EPersonService;
import org.dspace.eperson.service.GroupService;
import org.json.JSONArray;
import org.json.JSONObject;

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
public class LoginAction extends AbstractAction
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
        
        final HttpServletResponse httpResponse = (HttpServletResponse) objectModel.get(HttpEnvironment.HTTP_RESPONSE_OBJECT);
        
            HttpSession session = request.getSession();
            String access_token = (String)session.getAttribute("access_token");
            httpConnection http = new httpConnection();
            JSONObject json = new JSONObject(http.getData(access_token));
            
            JSONObject name = json.getJSONObject("name");
            JSONArray nombres = name.getJSONArray("nombres");
            JSONArray apellidos = name.getJSONArray("apellidos");
            
            String listaNombres = "";
            String listaApellidos = "";
            
            for(int i = 0; i<nombres.length(); i++)
            {
                listaNombres += nombres.get(i).toString()+" ";
            }
            for(int j = 0; j<apellidos.length(); j++)
            {
                listaApellidos += apellidos.get(j).toString()+" ";
            }
            
//        int sub = json.getInt("sub");
        JSONObject rolunico = json.getJSONObject("RolUnico");
            
        int rut = rolunico.getInt("numero");
        String dv = rolunico.getString("DV");
//        String tipo = rolunico.getString("tipo");
       
        String email = rut+dv+"@gob.cl";
        String password = rut+dv;
        String realm = request.getParameter("login_realm");
        
        session.setAttribute("email", email);
        session.setAttribute("auth", listaNombres+listaApellidos+rut+dv);
        
       Context context = AuthenticationUtil.authenticate(objectModel, email,password, realm); 
       EPerson eperson = null;
       context.turnOffAuthorisationSystem();
       eperson = ePersonService.findByEmail(context, email);

        // Protect against NPE errors inside the authentication
        // class.
        if ((email == null) || (password == null))
		{
			return null;
		}
        
        if (eperson != null)
        {
            // The user has successfully logged in
            String redirectURL = request.getContextPath();
            
            if (AuthenticationUtil.isInterupptedRequest(objectModel))
            {
                // Resume the request and set the redirect target URL to
                // that of the originally interrupted request.
                redirectURL += AuthenticationUtil.resumeInterruptedRequest(objectModel);
            }
            else
            {
                // Otherwise direct the user to the specified 'loginredirect' page (or homepage by default)
                String loginRedirect = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("xmlui.user.loginredirect");
                redirectURL += (loginRedirect != null) ? loginRedirect.trim() : "/";
            }
            
            // Authentication successful send a redirect.
            
            httpResponse.sendRedirect(redirectURL);
            
            // log the user out for the rest of this current request, however they will be reauthenticated
            // fully when they come back from the redirect. This prevents caching problems where part of the
            // request is performed before the user was authenticated and the other half after it succeeded. This
            // way the user is fully authenticated from the start of the request.
            context.setCurrentUser(null);
            
            return new HashMap();
        }
        
        return null;
    }

}
