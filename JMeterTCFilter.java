import org.jsoup.Jsoup;
import org.jsoup.helper.Validate;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;

public class JMeterTCFilter extends Task {

    private String htmlfile;

    public void setFile(String str){
        this.htmlfile= str;
    }

    public void execute() throws BuildException{
        String html = readFileAsString(htmlfile);
        String tcslug = "##teamcity[buildStatisticValue";
        Document doc = Jsoup.parse(html);
        Element title = doc.select("title").first();
        Elements tables = doc.getElementsByTag("table");
        Element summaryTable = tables.get(1);
        HashMap<Element,Element> hashMap = new HashMap<Element,Element>();
        Elements headers = summaryTable.getElementsByTag("th");
        Elements tdatas = summaryTable.getElementsByTag("td");
        for(int i=0;i < headers.size();i++){
//            hashMap.put(headers.get(i),tdatas.get(i));
//        }
//        for (Map.Entry<Element, Element> entry : hashMap.entrySet()) {
//            String key = entry.getKey().text();
            String key = headers.get(i).text();
//            String value = entry.getValue().text();
            String value = tdatas.get(i).text();
            key = key.replaceAll("\\s+", "");
            if(value.endsWith(" ms")){
              value = value.replace(" ms","");
            }
            if(value.endsWith("%")){
              value = value.replace("%","");
            }
            System.out.println(tcslug + " key='" + key + "' value='" + value + "']");
        }
    }
    
    private static String readFileAsString(String filePath) throws BuildException{
        byte[] buffer;
        try{
            buffer = new byte[(int) new java.io.File(filePath).length()];
            BufferedInputStream f = new BufferedInputStream(new FileInputStream(filePath));
            f.read(buffer);
            f.close();
        } catch(IOException e){
            throw new BuildException(e);
        }
        return new String(buffer);
    }
    
}
