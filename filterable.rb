module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      query_filters = []
      boolean_filter, array_filter, numeric_filter = separate_filters(filtering_params)

      keys = filtering_params.keys
      keys.each do |key|
        if( boolean_filter.key?(key) || numeric_filter.key?(key))
          query_filters << "#{key} = #{filtering_params[key]}"
        elsif array_filter.key?(key)
          query_filters << "#{key} IN (#{filtering_params[key].join(',')})"
        else 
          query_filters << "#{key} ILIKE '%#{filtering_params[key]}%'"
        end
      end
      query =  query_filters.join(' AND ')
      results = results.where("#{query}")
      results
    end

    def separate_filters(filtering_params)
      boolean_keys = []
      array_keys = []
      numeric_keys = []
      filtering_params.keys.map do |k|
        boolean_keys << k if( !!filtering_params[k] == filtering_params[k])
        array_keys << k if filtering_params[k].kind_of?(Array)
        numeric_keys << k if (filtering_params[k]).is_a?(Numeric)
      end

      boolean_filter = boolean_keys.inject({}){|h,k| h[k] = filtering_params[k]; h}
      array_filter = array_keys.inject({}){|h,k| h[k] = filtering_params[k]; h}
      numeric_filter = numeric_keys.inject({}){|h,k| h[k] = filtering_params[k]; h}

      return boolean_filter || [], array_filter || [], numeric_filter || []
    end
  end
end
