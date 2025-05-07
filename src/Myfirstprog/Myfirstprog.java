
public class Myfirstprog {
    public static void main(String[] args) {
        try {
            System.out.println("Hello, World!");
            Thread.sleep(60000); // Sleep for 60000 milliseconds (1 minute)
            System.out.println("Program finished after 1 minute.");
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
