module Rubillow
  module Models
    # List of updated attributes for a property.
    class UpdatedPropertyDetails < Base
      include Zpidable
      include Addressable
      include Linkable
      include Images
      
      # @return [Hash] number of page views (:current_month, :total).
      #
      # @example
      #   puts page_views[:current_month]
      #
      attr_accessor :page_views
      
      # @return [String] price.
      attr_accessor :price
      
      # @return [String] neighborhood.
      attr_accessor :neighborhood
      
      # @return [String] elementary school's name.
      attr_accessor :elementary_school
      
      # @return [String] middle school's name.
      attr_accessor :middle_school
      
      # @return [String] school district's name.
      attr_accessor :school_district
      
      # @return [String] Realtor provided home description
      attr_accessor :home_description
      
      # @return [Hash] posting information 
      #
      # @example
      #   posting.each do |key, value|
      #   end
      # 
      attr_accessor :posting
      
      # @return [Hash] list of edited facts
      #
      # @example
      #   edited_facts.each do |key, value|
      #   end
      #
      attr_accessor :edited_facts
      
      protected
      
      # @private
      def parse
        super
        
        return if !success?
        
        extract_zpid(@parser)
        extract_links(@parser)
        extract_address(@parser)
        extract_images(@parser)
        
        @page_views = {
          :current_month => @parser.xpath('//pageViewCount/currentMonth').first,
          :total => @parser.xpath('//pageViewCount/total').first
        }
        @price = @parser.xpath('//price').first
        @neighborhood = @parser.xpath('//neighborhood').first
        @school_district = @parser.xpath('//schoolDistrict').first
        @elementary_school = @parser.xpath('//elementarySchool').first
        @middle_school = @parser.xpath('//middleSchool').first
        @home_description = @parser.xpath('//homeDescription').first
        
        @posting = {}
        @parser.xpath('//posting').children.each do |elm|
          @posting[underscore(elm.name).to_sym] = elm
        end
        
        @edited_facts = {}
        @parser.xpath('//editedFacts').children.each do |elm|
          @edited_facts[underscore(elm.name).to_sym] = elm
        end

        extract_text_from_xml_elements
      end
      
      # @private
      def underscore(string)
        word = string.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.gsub!(/\-/, '_')
        word.downcase!
        word
      end

      # @private
      def extract_text_from_xml_elements
        [:@page_views, :@price, :@neighborhood, :@school_district,
         :@elementary_school, :@middle_school, :@home_description,
         :@posting, :@edited_facts].each do |variable_name|
          variable_value = self.instance_variable_get(variable_name)
          if variable_value.is_a? Hash
            text_value = variable_value.each do |h_key, h_value|
                           variable_value[h_key] = text_or_nil(h_value)
                         end
          else
            text_value = text_or_nil(variable_value)
          end
          self.instance_variable_set(variable_name, text_value)
        end
      end

      # @private
      def text_or_nil(value)
        value.text if value.respond_to? :text
      end
    end
  end
end
