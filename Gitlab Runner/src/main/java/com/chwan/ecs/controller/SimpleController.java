package com.chwan.ecs.controller;

import java.net.InetAddress;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.chwan.ecs.service.HelloService;

@Controller
public class SimpleController {

    private final Logger logger = LogManager.getLogger(SimpleController.class);
    
    @Autowired
    private HelloService helloService;
    @GetMapping("/")
    public String dashboard(Model model) throws Exception {
        model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
        model.addAttribute("host ip", InetAddress.getLocalHost().getHostAddress());
        if (Math.random() < 0.2) {
            model.addAttribute("content", helloService.getTest().get("content"));    
        } else {
            model.addAttribute("content", "normal");
        }

        final int availableProcessors = Runtime.getRuntime().availableProcessors();
        final long totalMemory = Runtime.getRuntime().totalMemory()/1024/1024;
        final long freeMemory = Runtime.getRuntime().freeMemory()/1024/1024;
        final long usedMemory = totalMemory - freeMemory;

        model.addAttribute("coreNum", availableProcessors+"");
        model.addAttribute("JVMTotal", totalMemory + "M");
        model.addAttribute("JVMUsed", usedMemory + "M");
        
        logger.warn("someone connect");
        return "index";
    }
}
