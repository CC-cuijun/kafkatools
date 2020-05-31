import org.apache.kafka.clients.producer.Producer;
import org.apache.log4j.Logger;

import java.io.*;
import java.util.ArrayList;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Created by cuijun on 5/8/17.
 */
public class KafkaProducer {

    private static Logger logger = Logger.getLogger(KafkaProducer.class);


    public static void main(String[] args) {
        Properties props = new Properties();

        try {
            File file = new File("config.properties");
            BufferedReader IN=new BufferedReader(new InputStreamReader(new FileInputStream(file),"utf-8"));
//            FileInputStream IN = new FileInputStream("config.properties");
//            InputStream IN = KafkaProducer.class.getClassLoader().getResourceAsStream("config.properties");
//            noinspection Since15
            props.load(IN);
        } catch (IOException e) {
            e.printStackTrace();
        }
        ArrayList producerlist = new ArrayList();
        int producerlistNumber = Integer.parseInt(props.getProperty("producerNumber"));
        for(int i=0;i<producerlistNumber;i++){
            Producer<Integer, byte[]> producer = new org.apache.kafka.clients.producer.KafkaProducer<Integer, byte[]>(props);
            producerlist.add(producer);
        }

        int THREAD_AMOUNT = Integer.parseInt(props.getProperty("THREAD_AMOUNT"));
        System.out.println("THREAD_AMOUNT:" + THREAD_AMOUNT);
        String TOPIC = props.getProperty("topic_name");
        ExecutorService executor = Executors.newFixedThreadPool(THREAD_AMOUNT);

        //线程开始时间
        Long time = System.currentTimeMillis();
        for (int i=0;i < THREAD_AMOUNT;i++) {

            executor.submit(new HandlMessageSender(producerlist,producerlistNumber,TOPIC));
/*            if(i==(THREAD_AMOUNT-10)){
                i=0;
            }*/
            try {
                int threadtime = Integer.parseInt(props.getProperty("THREAD_AMOUNT_time"));
                Thread.sleep(threadtime);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        logger.info("线程启动结束,耗时: " + (System.currentTimeMillis()-time));
    }
}
