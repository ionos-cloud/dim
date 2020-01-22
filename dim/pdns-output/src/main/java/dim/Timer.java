package dim;

class Timer {
    private long start = System.currentTimeMillis();

    double reset() {
        double elapsed = elapsed();
        start = System.currentTimeMillis();
        return elapsed;
    }

    double elapsed() {
        return (System.currentTimeMillis() - start) / 1000.0;
    }
}
