/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.eperson.openid;

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
public class CallbackAction extends AbstractAction
{
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
        
        if(request.getParameter("error") != null)
        {
            if(request.getParameter("error").equals("true"))
            {
                httpResponse.sendRedirect("/");
            }
        }
        
        
        HttpSession session = request.getSession();
        String tokenenviado = (String)session.getAttribute("token");
        String tokenrecibido = request.getParameter("state");
        
        if(tokenrecibido != null)
        {
        
        if(tokenenviado.equals(tokenrecibido))
        {
            String code = request.getParameter("code");
            
            httpConnection http = new httpConnection();
            session.setAttribute("access_token", http.getAccessToken(code, tokenrecibido));
            httpResponse.sendRedirect("/loginopenid");
            
            
            
        } else {
            return null;
        }
        } else {
            return null;
        }
        
        return null;
    }

}
