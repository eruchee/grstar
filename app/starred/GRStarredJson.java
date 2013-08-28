package starred;

import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.map.SerializationConfig;
import org.codehaus.jackson.node.ArrayNode;
import org.codehaus.jackson.node.ObjectNode;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;

/**
 * Created with IntelliJ IDEA.
 * User: eru
 * Date: 13/08/01
 * Time: 15:48
 * To change this template use File | Settings | File Templates.
 */
public class GRStarredJson {
    String jsonFile;
    ObjectNode rootNode;
    JsonNode itemsNode;
    ObjectMapper mapper;
    ArrayNode itemsArray;
    public GRStarredJson(String s){
        mapper = new ObjectMapper();
        jsonFile = s;
        try{
            rootNode = mapper.readValue(new File(jsonFile), ObjectNode.class);
            itemsNode = rootNode.get("items");
            itemsArray = mapper.readValue(itemsNode, ArrayNode.class);

        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public boolean delete(String id, int lastindex){
        //System.out.println("call to delete " + id);
        try{
           int volume = itemsArray.size();

            for(int i = 0 ; i < volume; i++){
                  //if (i > lastindex) return false;
                  JsonNode item = itemsArray.get(i);

                  //System.out.println(item.get("id").getTextValue() + " " + id);
                  if (item.get("id").getTextValue().equals(id)){
                      System.out.println("delete " + id + "     num" + i);
                      // delete this record
                      itemsArray.remove(i);
                      //volume--;  // NOP対策(タイミング上重複した削除リクエストが投げられた場合にforがOutOfBoundsする可能性があるので配列の範囲を超えないようにするため)

                      return true;
                  }
            }
            System.out.println("Not Found " + id);
            String fname = id;
            fname = fname.replace(':','_');
            fname = fname.replace('/','_');
            try{
                OutputStreamWriter osw = new OutputStreamWriter(new FileOutputStream(new File(fname)));
                BufferedWriter bw = new BufferedWriter(osw);
                bw.write("target: " + id);
                bw.newLine(); bw.newLine();
                for(JsonNode jn: itemsArray){
                    bw.write(jn.get("title").getTextValue()); bw.newLine();
                    bw.write(jn.get("id").getTextValue());
                    if(jn.get("id").getTextValue().equals(id)){
                        bw.write("match");
                        bw.newLine();
                    }
                    bw.newLine();
                }
                osw.close();
            } catch(Exception e){
                e.printStackTrace();
            }


        }catch(Exception e){
              e.printStackTrace();
          }
          return false;
    }

    public boolean additem(JsonNode j){
        //存在、不存在は確認せず、ArrayNodeの先頭に挿入する。
        itemsArray.insert(0,j);
        return true;
    }
    public void save(){
        try{
            rootNode.remove("items");
            rootNode.put("items", mapper.readValue(itemsArray, JsonNode.class));
            mapper.configure(SerializationConfig.Feature.INDENT_OUTPUT,true);
            mapper.writeValue(new File(jsonFile), rootNode);
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            return;
        }
    }

}
