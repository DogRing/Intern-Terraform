package com.chwan.ecs.service;

import java.io.BufferedReader;
import java.io.File;
import java.io.FilenameFilter;
import java.io.InputStreamReader;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.annotation.PreDestroy;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
// import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.chwan.ecs.dao.TestDao;

@Service
public class HelloService {
    private final Logger logger = LogManager.getLogger(HelloService.class);

    @Autowired
    private TestDao testDao;

    public Map<String, Object> getTest() throws Exception {
        return testDao.getName(1);
    }

    private final String DATA_DIRECTORY = "./logs";
    @Scheduled(fixedRate = 1000*60*30, initialDelay = 1000*60)
    public void logging_s3() {
        File log_dir = new File(DATA_DIRECTORY);

        FilenameFilter log_filter = new FilenameFilter() {
            public boolean accept(File f, String name) {
                return name.matches("log-.*");
            }
        };
        String[] log_files = log_dir.list(log_filter);

        File err_dir = new File(DATA_DIRECTORY + "/error");
        FilenameFilter err_filter = new FilenameFilter() {
            public boolean accept(File f, String name) {
                return name.matches("error-.*");
            }
        };
        String[] err_files = err_dir.list(err_filter);

        if(log_files.length != 0)
            to_s3(log_files, "/");
        if(err_files.length != 0)
            to_s3(err_files, "/error/");
    }
    
    @PreDestroy
    public void destroy() {
        logger.info("graceful shotdown");
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd-HH");
        String date = simpleDateFormat.format(new Date());
        String s;
        Process p;
        try {
            String[] cmd = { "/bin/sh", "-c", 
                    "aws s3 cp "+DATA_DIRECTORY+"/log.log s3://"+bucketname+"/logs/log-"+date+".`hostname -i`F.log" +
                    " && aws s3 cp "+DATA_DIRECTORY+"/error/error.log s3://"+bucketname+"/logs/error/error-"+date+".`hostname -i`F.error" };
            p = Runtime.getRuntime().exec(cmd);
            BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
            while ((s = br.readLine()) != null)
                logger.info(s);
            p.waitFor();
            p.destroy();
        } catch (Exception e) {
            e.printStackTrace();
        }
        logging_s3();
    }
    
    @Value("${bucket.name}")
    String bucketname;
    private void to_s3(String[] filenames, String dir) {
        for (String filename : filenames) {
            logger.info(filename);
            String s;
            Process p;
            try {
                String[] cmd = { "/bin/sh", "-c",
                        "aws s3 cp " +DATA_DIRECTORY+dir+filename + " s3://"+bucketname+"/logs"+dir+filename+".`hostname -i`.log"+
                                " && rm " +DATA_DIRECTORY+dir+filename };
                p = Runtime.getRuntime().exec(cmd);
                BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
                while ((s = br.readLine()) != null)
                    logger.info(s);
                p.waitFor();
                p.destroy();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    // @Async
    // public void stressCpu(String time, String core) {
    //     String s;
    //     Process p;
    //     try {
    //         String[] cmd = { "/bin/sh", "-c", "stress -c "+core+" --timeout "+time };
    //         p = Runtime.getRuntime().exec(cmd);
    //         BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    //         while ((s = br.readLine()) != null)
    //             System.out.println(s);
    //         p.waitFor();
    //         System.out.println("exit: " + p.exitValue());
    //         p.destroy();
    //     } catch (Exception e) {
    //         e.printStackTrace();
    //     }
    // }
    // @Async
    // public void stressMem(String time, String Mbyte) {
    //     String s;
    //     Process p;
    //     try {
    //         String[] cmd = { "/bin/sh", "-c", "stress -vm 1 -vm-bytes "+Mbyte+"m --timeout "+time };
    //         p = Runtime.getRuntime().exec(cmd);
    //         BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    //         while ((s = br.readLine()) != null)
    //             System.out.println(s);
    //         p.waitFor();
    //         System.out.println("exit: " + p.exitValue());
    //         p.destroy();
    //     } catch (Exception e) {
    //         e.printStackTrace();
    //     }
    // }
}


