package org.ulutas.flink.context.flink;

import org.apache.flink.api.common.functions.MapFunction;

import java.util.Locale;

public class WordsCapitalizer implements MapFunction<String, String> {

    @Override
    public String map(String s) {
        return s.toUpperCase(Locale.forLanguageTag("tr-TR"));
    }

}
