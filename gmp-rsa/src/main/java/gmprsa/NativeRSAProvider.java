package gmprsa;

import java.security.Provider;

public class NativeRSAProvider extends Provider {
    public NativeRSAProvider() {
        super("native-rsa", 1.0, "SHA Digest with RSA Native implementation");
        put("Signature.SHA1withRSA", NativeDigestSignatureSpi.SHA1.class.getName());
        put("Signature.SHA256withRSA", NativeDigestSignatureSpi.SHA256.class.getName());
        put("Signature.SHA512withRSA", NativeDigestSignatureSpi.SHA512.class.getName());
    }
}
