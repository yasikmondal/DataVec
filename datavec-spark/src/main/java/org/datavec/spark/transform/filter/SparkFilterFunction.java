/*-
 *  * Copyright 2016 Skymind, Inc.
 *  *
 *  *    Licensed under the Apache License, Version 2.0 (the "License");
 *  *    you may not use this file except in compliance with the License.
 *  *    You may obtain a copy of the License at
 *  *
 *  *        http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  *    Unless required by applicable law or agreed to in writing, software
 *  *    distributed under the License is distributed on an "AS IS" BASIS,
 *  *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  *    See the License for the specific language governing permissions and
 *  *    limitations under the License.
 */

package org.datavec.spark.transform.filter;

import lombok.AllArgsConstructor;
import org.apache.spark.api.java.function.Function;
import org.datavec.api.writable.Writable;
import org.datavec.api.transform.filter.Filter;

import java.util.List;

/**
 * Spark function for executing filter operations
 * @author Alex Black
 */
@AllArgsConstructor
public class SparkFilterFunction implements Function<List<Writable>, Boolean> {

    private final Filter filter;

    @Override
    public Boolean call(List<Writable> v1) throws Exception {
        return !filter.removeExample(v1); //Spark: return true to keep example (Filter: return true to remove)
    }
}
