package controllers;

import org.codehaus.jackson.JsonNode;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.node.ArrayNode;
import org.codehaus.jackson.node.JsonNodeFactory;
import org.codehaus.jackson.node.ObjectNode;
import play.libs.Json;
import play.mvc.*;
import tastesgood.DeliciousController;
import starred.GRStarredJson;
import views.html.*;

import static controllers.routes.Application;
import static controllers.routes.Assets;

public class Application extends Controller {
    public static final int NO_OPRATION = 0;
    public static final int DELETE_FROM_JSON = 101;
    public static final int WRITEBACK_TO_JSON = 110;
    public static final int ADD_DELICIOUS            = 200;
    public static final int ADD_DELICIOUS_ASYNC     = 210;

    public static Result index() {
        return ok(index.render("Your new application is ready."));
    }

    //Client Control Buffer Entry
    public static Result procCCB(){
        int handleId = 0;
        int listIndex = 0;
        int ccbpos = 0;
        boolean needWrite = false;
        ObjectMapper mapper = new ObjectMapper();
        ArrayNode returnNodes = mapper.createArrayNode();
        String jsonId = "";
        JsonNode json = request().body().asJson();
        JsonNode response = request().body().asJson();
        ObjectNode result = mapper.createObjectNode();


        //System.out.println("get:" + json);
        if(json == null) {
            result.put("result","fail");
            result.put("describe","null");
            returnNodes.add(result);
            return ok(returnNodes);
        } else {
            GRStarredJson grs = new GRStarredJson("public/starred.json");
            int lastindex = json.get("lastIndex").getIntValue();
            JsonNode ccbNodes = json.get("ccb");



            for(JsonNode jn : ccbNodes){
                //load starred.json
                if(jn.has("handleID")){
                    handleId = jn.findPath("handleID").getIntValue();
                    listIndex = jn.findPath("listID").getIntValue();
                    ccbpos =jn.findPath("ccbpos").getIntValue();
                    jsonId = jn.findPath("jsonID").getTextValue();
                }
                System.out.println("ID: " + handleId + " " + jsonId);
                //Exit functions
                boolean res = false;
                switch (handleId){
                    case controllers.Application.DELETE_FROM_JSON:
                        res = grs.delete(jsonId,lastindex);
                        result = mapper.createObjectNode();
                        result.put("ccbpos",ccbpos);
                        result.put("listIndex",listIndex);
                        result.put("jsonID", jsonId);
                        if (res == false){
                            result.put("result","fail");
                        }else{
                            result.put("result","ok");
                        }
                        returnNodes.add(result);
                        needWrite |= res;
                        break;
                    case controllers.Application.WRITEBACK_TO_JSON:
                        //むしろ、itemをJSONに書き戻さなくてはいけない。
                        res = grs.additem(jn.get("json"));
                        result = mapper.createObjectNode();
                        result.put("ccbpos",ccbpos);
                        result.put("listIndex",listIndex);
                        result.put("jsonID",jsonId);
                        if (res == false){
                            result.put("result","fail");
                            result.put("json", jn.findPath("json"));
                        }else{
                            result.put("result","ok");
                        }
                        returnNodes.add(result);

                        needWrite |= res;
                        break;
                    case controllers.Application.ADD_DELICIOUS:
                        break;
                }

            }
            if (needWrite){
                // write json
                grs.save();
                needWrite = false;
            }
        }
        /*
        switch (handleId){
            case  controllers.Application.DELETE_FROM_JSON:
                    if ( returnNodes.size()==0){
                        result.put("result", "ok");
                        result.put("describe","no comment");
                        returnNodes.add(result);
                    }else{
                        //多重実行対策（同時に同じアイテムを削除すると後発はエラーになるから）
                        result.put("result","ok");
                        result.put("describe","contains not found item");
                        returnNodes.add(result);
                    }
                    break;
                case controllers.Application.WRITEBACK_TO_JSON:
                    result.put("result", "ok");
                    result.put("describe","refresh");
                    returnNodes.add(result);
        } */
        return ok(returnNodes);
    }

    public static Result addDelicious(){
        JsonNode json = request().body().asJson();
        ObjectNode result = Json.newObject();
        //直近の更新情報はH2 memdbに追加しておく
        //最も過去の時間とそこからの合計回数のみconfに揮発化
        //deliciousのハンドリングは後回しだが、別クラス
        /*   形式
        　　 tastesgood.times    追加した回数
             tastesgood.time.n   追加した時間（直近一時間以上前は追放）
             tastesgood.count.n  追加した件数
        */


        result.put("result","OK");

        //不揮発化して、時間がたってからまとめ書きが必要な場合があるかもしれない。

        return ok();
    }
  
}
