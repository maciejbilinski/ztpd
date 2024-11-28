package app.lucene;

import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.*;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;

import java.io.IOException;
import java.nio.file.Paths;
import java.util.Scanner;

//
public class Search {
    public static void main(String[] args) throws IOException, ParseException {
        String indexDirectoryPath = "index";
        Directory directory = FSDirectory.open(Paths.get(indexDirectoryPath));

        Analyzer analyzer = new PolishAnalyzer();
        IndexReader reader = DirectoryReader.open(directory);
        IndexSearcher searcher = new IndexSearcher(reader);

        Scanner scanner = new Scanner(System.in);
        System.out.print("Czy chcesz szukać po ISBN czy po tytule? [isbn/title]: ");
        String searchField = scanner.nextLine();
        System.out.print("Podaj zapytanie: ");
        String querystr = scanner.nextLine();
        String field = "isbn".equalsIgnoreCase(searchField) ? "isbn" : "title";
        Query query = new QueryParser(field, analyzer).parse(querystr);

        int maxHits = 10;
        TopDocs topDocs = searcher.search(query, maxHits);
        ScoreDoc[] hits = topDocs.scoreDocs;

        System.out.println("Found " + hits.length + " matching docs.");
        for (int i = 0; i < hits.length; ++i) {
            int docId = hits[i].doc;
            Document doc = searcher.doc(docId);
            System.out.println((i + 1) + ". " + doc.get("isbn") + "\t" + doc.get("title"));
        }

        reader.close();
    }
}
