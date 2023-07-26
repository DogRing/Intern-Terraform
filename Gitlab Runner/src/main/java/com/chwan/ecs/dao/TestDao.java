package com.chwan.ecs.dao;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class TestDao {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    public Map<String, Object> getName(int seq) throws Exception {
        return jdbcTemplate.queryForMap(" select content from testtable where id = ? ", seq);
    }
}
