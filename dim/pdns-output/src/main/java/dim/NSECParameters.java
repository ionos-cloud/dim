package dim;

import org.xbill.DNS.utils.base16;

public class NSECParameters {
    enum NSECMode {NSEC_MODE, NSEC3_MODE}

    final NSECMode nsecMode;
    final byte[] salt;
    final int iterations;

    private NSECParameters(NSECMode nsecMode, int iterations, byte[] salt) {
        this.nsecMode = nsecMode;
        this.iterations = iterations;
        this.salt = salt;
    }

    public static NSECParameters NSEC() {
        return new NSECParameters(NSECMode.NSEC_MODE, 0, null);
    }

    public static NSECParameters NSEC3(int iterations, byte[] salt) {
        return new NSECParameters(NSECMode.NSEC3_MODE, iterations, salt);
    }

    public static NSECParameters fromString(String s) {
        if (s != null) {
            String[] p = s.split("\\s+");
            if (p.length == 4)
                try {
                    byte[] salt = null;
                    if (!p[3].equals("-"))
                        salt = base16.fromString(p[3]);
                    return NSECParameters.NSEC3(Integer.parseInt(p[2]), salt);
                } catch (Exception e) {
                }
        }
        return NSECParameters.NSEC();
    }

    public String toString() {
        if (nsecMode == NSECMode.NSEC_MODE)
            return "";
        return "1 0 " + iterations + " " + (salt == null || salt.length == 0 ? "-" : base16.toString(salt));
    }
}
