package com.chwan.ecs.controller;

// import java.net.InetAddress;
// import java.net.UnknownHostException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
// import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.chwan.ecs.service.HelloService;

@RestController
public class SimpleRestController {
    private final Logger logger = LogManager.getLogger(SimpleController.class);

    @Autowired
    private HelloService helloService;
    
    @GetMapping("/db")
    public Map<String, Object> dbconn() throws Exception {
        logger.warn("db connect");
        return helloService.getTest();
    }
    
    @GetMapping("/bad")
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public void badRequest(HttpServletRequest request) throws Exception {
        logger.warn("BAD REQUEST from " + request.getRemoteAddr());
    }
    
    @GetMapping("/ok")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public void okRequest(HttpServletRequest request) throws Exception {
        logger.info("ACCEPED REQUEST from " + request.getRemoteAddr());
    }

    // @GetMapping("/stressCpu")
    // public String stressTest(@RequestParam(value = "t", defaultValue = "180") String time,
    //                         @RequestParam(value = "c", defaultValue = "1") String core) throws UnknownHostException {
    //     helloService.stressCpu(time, core);
    //     return "stress cpu on " + InetAddress.getLocalHost().getHostAddress() + " " + time + "S";
    // }
    
    // @GetMapping("/stressMem")
    // public String stressMem(@RequestParam(value = "t", defaultValue = "180") String time,
    //                         @RequestParam(value = "b", defaultValue = "128") String Mbyte) throws UnknownHostException {
    //     helloService.stressMem(time, Mbyte);
    //     return "stress mem on " + InetAddress.getLocalHost().getHostAddress() + " " + time + "S";
    // }
}
