import java.io.*;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Scanner;

public class MtxToCscConverter {
    @SuppressWarnings("ResultOfMethodCallIgnored")
    public static void main(String[] args) throws IOException {
        if (args == null || args.length < 2) {
            System.out.println("Использование: [входной файл] [выходной файл]");
            System.exit(1);
        }
        File input = new File(args[0]);
        File output = new File(args[1]);
        if (!input.exists() || !input.canRead()) {
            System.out.printf("Файл \"%s\" не существует или нет прав на чтение\n", input.getAbsolutePath());
            System.exit(2);
        }
        if (output.isDirectory()) {
            System.out.printf("\"%s\" - это директория\n", output.getAbsolutePath());
            System.exit(3);
        }
        if (output.exists() && output.isFile() && output.canWrite()) {
            System.out.printf("Файл \"%s\" уже существует. Перезаписать?\n", output.getAbsolutePath());
            Scanner scanner = new Scanner(System.in);
            String answer = scanner.nextLine();
            if (!answer.equalsIgnoreCase("y") && !answer.equalsIgnoreCase("д")) System.exit(4);
        }
        int skip = 2;
        String line;
        LinkedList<String> rows = new LinkedList<>();
        LinkedList<String> cols = new LinkedList<>();
        LinkedList<String> values = new LinkedList<>();
        BufferedReader reader = new BufferedReader(new FileReader(input));
        while ((line = reader.readLine()) != null) {
            if (skip-- > 0) continue;
            String[] digits = line.split("\\s+");
            rows.add(digits[0].trim() + " ");
            cols.add(digits[1].trim() + " ");
            values.add(digits[2].trim() + " ");
        }
        reader.close();
        output.delete();
        output.createNewFile();
        FileOutputStream outputStream = new FileOutputStream(output);
        rows.stream().map(String::getBytes).forEach(r -> {
            try {
                outputStream.write(r);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        outputStream.write("\n".getBytes());
        cols.stream().map(String::getBytes).forEach(c -> {
            try {
                outputStream.write(c);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        outputStream.write("\n".getBytes());
        values.stream().map(String::getBytes).forEach(v -> {
            try {
                outputStream.write(v);
            } catch (IOException e) {
                e.printStackTrace();
            }
        });
        outputStream.close();
        System.out.println("Конвертация выполнена");
    }
}
