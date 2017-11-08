/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.xmlui.aspect.eperson.openid;

/**
 *
 * @author hernan
 */
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLEncoder;

import javax.net.ssl.HttpsURLConnection;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.json.JSONObject;

public class httpConnection {

        private static final String TOKEN_URL = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.token_url");
        private static final String RETURN_URL = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.return_url");
        private static final String SECRET_ID = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.secret_id");
        private static final String CLIENT_ID = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.client_id");
        private static final String AUTORIZATION_CODE = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.grant_type");
        private static final String USERINFO_URL = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("org.dspace.app.xmlui.aspect.eperson.openid.userinfo_url");

	// HTTP POST request
	public String getAccessToken(String code, String state) throws Exception {

		URL obj = new URL(TOKEN_URL);
		HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

		//agregar request header
		con.setRequestMethod("POST");
                con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                con.setRequestProperty("HOST", "https://www.claveunica.gob.cl");
                con.setRequestProperty("cache-control", "no-cache");
                
                String return_redirect = (RETURN_URL != null) ? RETURN_URL.trim() : "https://biblioteca.digital.gob.cl/callback";
                String redirect = URLEncoder.encode(return_redirect, "UTF-8");
                
		String urlParameters = "client_id="+CLIENT_ID+"&"
                        + "client_secret="+SECRET_ID+"&"
                        + "redirect_uri="+redirect+"&"
                        + "grant_type="+AUTORIZATION_CODE+"&"
                        + "code="+code
                        + "&state="+state;

		// Send post request
		con.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
		wr.writeBytes(urlParameters);
		wr.flush();
		wr.close();

		

		BufferedReader in = new BufferedReader(
		        new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();

		while ((inputLine = in.readLine()) != null) {
			response.append(inputLine);
		}
		in.close();
                
                //Crear JSON
                JSONObject json = new JSONObject(response.toString());

		//print result
		return json.getString("access_token");

	}
        
        
        
        
        public String getData(String access_token) throws Exception {

		URL obj = new URL(USERINFO_URL);
		HttpsURLConnection con = (HttpsURLConnection) obj.openConnection();

		//add reuqest header
		con.setRequestMethod("POST");
                con.setRequestProperty("HOST", "https://www.claveunica.gob.cl");
                con.setRequestProperty  ("Authorization", "Bearer " + access_token);
                


		// Send post request
		con.setDoOutput(true);
		DataOutputStream wr = new DataOutputStream(con.getOutputStream());
//		wr.writeBytes(urlParameters);
		wr.flush();
		wr.close();

		BufferedReader in = new BufferedReader(
		        new InputStreamReader(con.getInputStream()));
		String inputLine;
		StringBuffer response = new StringBuffer();

		while ((inputLine = in.readLine()) != null) {
			response.append(inputLine);
		}
		in.close();
                

		//print result
		return response.toString();

	}
        

}

