package org.datavec.dataframe.filtering.text;

import org.datavec.dataframe.api.CategoryColumn;
import org.datavec.dataframe.api.Table;
import org.datavec.dataframe.columns.Column;
import org.datavec.dataframe.columns.ColumnReference;
import org.datavec.dataframe.filtering.ColumnFilter;
import org.datavec.dataframe.util.Selection;

import net.jcip.annotations.Immutable;

/**
 * A filtering that selects cells in which all text is uppercase
 */
@Immutable
public class TextIsShorterThan extends ColumnFilter {

    private int length;

    public TextIsShorterThan(ColumnReference reference, int length) {
        super(reference);
        this.length = length;
    }

    @Override
    public Selection apply(Table relation) {
        Column column = relation.column(columnReference().getColumnName());
        CategoryColumn textColumn = (CategoryColumn) column;
        return textColumn.isShorterThan(length);
    }
}
