module FabricationMethods
  def create_from_table(model_name, table, extra = {})
    fabricator_name = generate_fabricator_name(model_name)
    is_singular = model_name.to_s.singularize == model_name.to_s
    hashes = is_singular ? [table.rows_hash] : table.hashes
    @they = hashes.map do |hash|
      hash = hash.merge(extra).inject({}) {|h,(k,v)| h.update(k.gsub(/\W+/,'_').to_sym => v)}
      Fabricate(fabricator_name, hash)
    end
    if is_singular
      @it = @they.last
      instance_variable_set("@#{fabricator_name}", @it)
    end
  end

  def create_with_default_attributes(model_name, count, extra = {})
    fabricator_name = generate_fabricator_name(model_name)
    is_singular = count == 1
    @they = count.times.map { Fabricate(fabricator_name, extra) }
    if is_singular
      @it = @they.last
      instance_variable_set("@#{fabricator_name}", @it)
    end
  end

  def generate_fabricator_name(model_name)
    model_name.gsub(/\W+/, '_').downcase.singularize.to_sym
  end
end

World(FabricationMethods)

When /^I delete that ([^"]*)$/ do |model_name|
  instance_variable_get("@#{model_name.gsub(/\W+/,'_').downcase.sub(/^_/, '')}").destroy
end

Given /^(\d+) ([^"]*)$/ do |count, model_name|
  create_with_default_attributes(model_name, count.to_i)
end

Given /^the following ([^"]*):$/ do |model_name, table|
  create_from_table(model_name, table)
end

Given /^that ([^"]*) has the following ([^"]*):$/ do |parent, child, table|
  parent = parent.gsub(/\W+/,'_').downcase.sub(/^_/, '')
  parent_instance = instance_variable_get("@#{parent}")
  child = child.gsub(/\W+/,'_').downcase

  child_class = Fabrication::Support.class_for(child.singularize)
  if child_class && !child_class.new.respond_to?("#{parent}=")
    parent = parent.pluralize
    parent_instance = [parent_instance]
  end

  create_from_table(child, table, parent => parent_instance)
end

Given /^that ([^"]*) belongs to that ([^"]*)$/ do |parent, child|
  p_instance = instance_variable_get("@#{parent.gsub(/\W+/,'_').downcase.sub(/^_/, '')}")
  c_instance = instance_variable_get("@#{child.gsub(/\W+/,'_').downcase.sub(/^_/, '')}")
  eval("p_instance.#{child}s << c_instance")
  c_instance.save!
end

Given /^one account that has passed group validation$/ do
  @account = Account.new(username: "bcassell", active: true)
  @account.save(:validate => false)
end


