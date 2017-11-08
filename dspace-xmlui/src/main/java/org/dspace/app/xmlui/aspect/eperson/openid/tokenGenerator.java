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
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author hernan
 */
public class tokenGenerator {
    
    private SecureRandom random = new SecureRandom();

    public SecureRandom getRandom() {
        return random;
    }
    
    //Se genera un token aleatorio
    private synchronized String generateToken() {
            
                long longToken = Math.abs( this.getRandom().nextLong() );
                String randoms = Long.toString( longToken, 16 );
                return (randoms);
    }
    
    //Se crea hash sha1
    public String generateHash() throws NoSuchAlgorithmException 
    {
        
        try {
            String input = this.generateToken();
            MessageDigest md = MessageDigest.getInstance("SHA1");
            md.reset();
            byte[] buffer = input.getBytes("UTF-8");
            md.update(buffer);
            byte[] digest = md.digest();

            String hexStr = "";
            for (int i = 0; i < digest.length; i++) {
                hexStr +=  Integer.toString( ( digest[i] & 0xff ) + 0x100, 16).substring( 1 );
            }
            return hexStr;
        } catch (UnsupportedEncodingException ex) {
            Logger.getLogger(tokenGenerator.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
    
}
