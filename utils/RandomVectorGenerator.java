import java.security.SecureRandom;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

public class RandomVectorGenerator {
    public static void main(String[] args) {
        if (args == null || args.length < 2) {
            System.out.println("Использование: [необходимая длина] [вероятность ненулевого значения (в %)]");
            System.exit(1);
        }
        SecureRandom random = new SecureRandom();
        random.setSeed(new Date().getTime());
        Integer length = null, zeroChance = null;
        try {
            length = Integer.parseInt(args[0]);
            zeroChance = Integer.parseInt(args[1]);
        } catch (NumberFormatException e) {
            System.out.printf("Ошибка преобразования значений \"%s\", \"%s\" к типу Integer\n", args[0], args[1]);
            System.exit(2);
        }
        List<Integer> indices = new LinkedList<>();
        List<Double> values = new LinkedList<>();
        do {
            for (int i = 1; i <= length; i++) {
                if (Math.abs(random.nextInt()) % 100 + 1 > zeroChance) {
                    indices.add(i);
                    values.add(random.nextDouble() * 1000);
                }
            }
        } while (indices.isEmpty());
        if (!indices.get(indices.size() - 1).equals(length)) {
            indices.add(length);
            values.add(0.0);
        }
        indices.stream().map(i -> i + " ").forEach(System.out::print);
        System.out.println();
        values.stream().map(v -> v + " ").forEach(System.out::print);
    }
}
