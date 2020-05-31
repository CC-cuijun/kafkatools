/**
 * Created by cuijun on 5/12/17.
 */

import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.log4j.Logger;

import java.io.*;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Random;

class HandlMessageSender implements Runnable {

    private static Logger logger = Logger.getLogger(KafkaProducer.class);

    private ArrayList producerlist;
    private String TOPIC;
    private int producerlistNumber;

    private int sendtime;
    private Long basePhone;
    private Long baseNum;
    private String baseVin;
    private String baseSn;
    private String baseImei;
    private String baseIccid;


    public HandlMessageSender( ArrayList producerlist, int producerlistNumber,String TOPIC) {
        super();
        this.producerlist = producerlist;
        this.TOPIC = TOPIC;
        this.producerlistNumber=producerlistNumber;

    }

    public void run() {
        String message = null;
        int send_num = 0;

        try {
            File file = new File("message.properties");
            BufferedReader br=new BufferedReader(new InputStreamReader(new FileInputStream(file),"utf-8"));
//            InputStreamReader messageAll = new InputStreamReader(HandlMessageSender.class.getClassLoader().getResourceAsStream("message.properties"), "UTF-8");
            Properties messageres = new Properties();
            //noinspection Since15
            messageres.load(br);
            String messageName = messageres.getProperty("messagetype");
            message = messageres.getProperty(messageName);
            send_num = Integer.parseInt(messageres.getProperty("send_num"));
            sendtime = Integer.parseInt(messageres.getProperty("send_time"));

            basePhone = Long.parseLong(messageres.getProperty("basePhone"));
            baseNum = Long.parseLong(messageres.getProperty("baseNum"));
            baseVin = messageres.getProperty("baseVin");
            baseSn = messageres.getProperty("baseSn");
            baseImei = messageres.getProperty("baseImei");
            baseIccid = messageres.getProperty("baseIccid");

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        Long timestamp = System.currentTimeMillis();
        String originalMsg = message;

        for(int i=0; i < send_num; i++){


            String str="0123456789";
            Random randomstring=new Random();
            StringBuffer vinum=new StringBuffer();
            for(int j=0;j<6;j++){
                int number=randomstring.nextInt(10);
                vinum.append(str.charAt(number));
            }
            vinum.toString();

            String phone = Long.toString(basePhone + i);
            String num = Long.toString(baseNum + i);
            String vin = baseVin+vinum;
//            String vin = previn+num;
//            System.out.printf("vin:" + vin + "\n");
            String sn = baseSn.concat(num);
            String imei = baseImei.concat(num);
            String iccid = baseIccid.concat(num);

            timestamp = System.currentTimeMillis();
            message = originalMsg.replaceAll("oldvin",vin).replaceAll("oldimei",imei).replaceAll("oldiccid",iccid).replaceAll("timeStampNow", timestamp.toString());

            //message可以带key, 根据key来将消息分配到指定区, 如果没有key则随机分配到某个区
            //KeyedMessage<Integer, String> keyedMessage = new KeyedMessage<Integer, String>("test", 1, message);
//            System.out.println(message);
            Random random=new java.util.Random();// 定义随机类
            int x=random.nextInt(producerlistNumber);
            ProducerRecord<Integer,byte[]> keyedMessage = new ProducerRecord(TOPIC, message.getBytes());
            Producer<Integer, byte[]> producer = (Producer<Integer, byte[]>) producerlist.get(x);
                    producer.send(keyedMessage,null);
//                    send(new KeyedMessage<String, String>(TOPIC,message));
            logger.info("send message to " + vin + ": " + timestamp);
            try {
                Thread.sleep(sendtime);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        }
        //producer.close();
    }

}
