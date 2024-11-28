package app.lucene;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.Scanner;

// po uruchomieniu drugi raz powstały nowe pliki .cfe, .cfs, .si z przedrostkiem _1 zamiast _0. segments_1 zamieniło się w segments_2
// uruchamiając drugi raz Search.java i wpisując Query "akcja" z parametrem szukania "title" dostajemy dwa razy więcej dokumentów (duplikaty)
public class Index {
    private static Document buildDoc(String title, String isbn) {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        return doc;
    }

    public static void main(String[] args) throws IOException {
        String indexDirectoryPath = "index";
        Directory directory = FSDirectory.open(Paths.get(indexDirectoryPath));

        Analyzer analyzer = new PolishAnalyzer();
        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        IndexWriter writer = new IndexWriter(directory, config);

        writer.addDocument(buildDoc("Lucyna w akcji", "9780062316097"));
        writer.addDocument(buildDoc("Akcje rosną i spadają", "9780385545955"));
        writer.addDocument(buildDoc("Bo ponieważ", "9781501168007"));
        writer.addDocument(buildDoc("Naturalnie urodzeni mordercy", "9780316485616"));
        writer.addDocument(buildDoc("Druhna rodzi", "9780593301760"));
        writer.addDocument(buildDoc("Urodzić się na nowo", "9780679777489"));

        Scanner scanner = new Scanner(System.in);
        System.out.print("Czy chcesz coś dodać do indeksu? [y/n]: ");
        String answer = scanner.nextLine();

        if ("y".equalsIgnoreCase(answer)) {
            System.out.print("Podaj tytuł książki: ");
            String title = scanner.nextLine();
            System.out.print("Podaj ISBN książki: ");
            String isbn = scanner.nextLine();
            writer.addDocument(buildDoc(title, isbn));
            System.out.println("Dokument dodany do indeksu.");
        }

        writer.close();
    }
}
