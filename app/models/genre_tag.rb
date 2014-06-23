class GenreTag
  attr_reader :id, :name, :cn, :en
  
  def initialize(id, name, cn, en)
    @id = id
    @name = name  # name is used in urls, thus they are the same as :en except have _ instead of spaces
    @cn = cn
    @en = en
  end

  # return all tags.  Caches the list.  To hit the db every time, use find()
  def self.all
    @@_cached_tags
  end
  
  def self.grouped_by_3
    @@_grouped_by_3
  end
  
  def self.by_id(id)
    @@_tags_by_id[id]
  end
  
  def self.by_name(name)
    @@_tags_by_name[name]
  end
  
  private
  def self.create_tags()
    array = []
    create_tag(array, self.new(1, "time-travel", "穿越时空", "time travel"))
    create_tag(array, self.new(2, "history", "历史言情", "history"))
    create_tag(array, self.new(3, "mixed-time", "架空历史", "mixed-time"))
    create_tag(array, self.new(4, "school", "青葱校园", "school"))
    create_tag(array, self.new(5, "growing-together", "青梅竹马", "growing together"))
    create_tag(array, self.new(6, "warm", "温馨甜文", "warm"))
    create_tag(array, self.new(7, "western-romance", "西方浪漫", "western romance"))
    create_tag(array, self.new(8, "comedy", "爆笑喜剧", "comedy"))
    create_tag(array, self.new(9, "modern", "现代都市", "modern"))
    create_tag(array, self.new(10, "swordsman-romance", "武侠言情", "swordsman romance"))
    create_tag(array, self.new(11, "extortion", "强取豪夺", "extortion"))
    create_tag(array, self.new(12, "former-and-current-life", "前世今生", "former and current life"))
    create_tag(array, self.new(13, "maternal-society", "女尊女权", "maternal society"))
    create_tag(array, self.new(14, "rich-and-old-family", "豪门世家", "rich and old family"))
    create_tag(array, self.new(15, "true-love", "情有独钟", "true-love"))
    create_tag(array, self.new(16, "love-to-kill", "虐恋情深", "love to kill"))
    create_tag(array, self.new(17, "happy-ending", "欢喜结局", "happy ending"))
    create_tag(array, self.new(18, "reborn", "再世重生", "reborn"))
    create_tag(array, self.new(19, "sexual", "情色撩人", "sexual"))
    create_tag(array, self.new(20, "gods-and-spirits", "仙侠神怪", "gods and spirits"))
    create_tag(array, self.new(21, "fantasy", "玄幻灵异", "fantasy"))
    create_tag(array, self.new(22, "couple-reconciliation", "破镜重圆", "couple reconciliation"))
    create_tag(array, self.new(23, "royal", "宫廷侯爵", "royal"))
    create_tag(array, self.new(24, "senior-officials-and-political", "高干文", "senior officials and political"))
    create_tag(array, self.new(25, "republic-of-china", "民国旧影", "Republic of China"))
    create_tag(array, self.new(26, "science-fiction-romance", "科幻言情", "science fiction romance"))
    create_tag(array, self.new(27, "derived-fiction", "同人故事", "derived fiction"))
    create_tag(array, self.new(28, "woman-dressed-as-man", "女扮男装", "woman dressed as man"))
    create_tag(array, self.new(29, "army", "军人故事", "army"))
    create_tag(array, self.new(30, "taiwan-romance", "台湾言情", "Taiwan romance"))
    create_tag(array, self.new(31, "antique-flavor", "古色古香", "antique flavor"))
    create_tag(array, self.new(32, "mafia-romance", "黑帮情仇", "mafia romance"))
    create_tag(array, self.new(33, "emperor-and-empress", "帝王后妃", "Emperor and Empress"))
    create_tag(array, self.new(34, "ethical-taboo", "伦理禁忌", "ethical taboo"))
    create_tag(array, self.new(35, "multiple-lovers", "一女n男", "multiple lovers"))
    create_tag(array, self.new(36, "boys-love", "耽美言情", "boys love"))
    create_tag(array, self.new(37, "suspense-legend", "悬疑传奇", "suspense legend"))
    create_tag(array, self.new(38, "big-family", "家长里短", "big family"))
    create_tag(array, self.new(39, "game-romance", "网游故事", "game romance"))
    create_tag(array, self.new(40, "love-after-marrige", "婚后恋爱", "love after marrige"))
    array
  end
  
  def self.create_tag(array, tag)
    # unless (Merb::Config[:mihudie][:suppress_tags] && Merb::Config[:mihudie][:suppress_tags].include?(tag.id))
      array << tag
    # end
    array
  end
  
  def self.hash_tags_by_id()
    tags_by_id = {}
    @@_cached_tags.each { |tag| tags_by_id[tag.id] = tag }
    tags_by_id
  end
  
  def self.hash_tags_by_name()
    tags_by_name = {}
    @@_cached_tags.each { |tag| tags_by_name[tag.name] = tag}
    tags_by_name
  end
  
  def self.create_grouped_by_3
    subarray = []
    array = []
    array << subarray
    counter = -1
    # size = self.all.size
    all.each do |tag|
      # don't add suppressed tags
      unless (Rails.configuration.mihudie.suppress_tags && Rails.configuration.mihudie.suppress_tags.include?(tag.id))
        counter = counter + 1
        if ((counter % 3) == 0)
          subarray = []
          array << subarray
        end
        subarray << tag
      end
    end
    array
  end
  
  @@_cached_tags = create_tags()
  @@_grouped_by_3 = create_grouped_by_3
  @@_tags_by_id = hash_tags_by_id()
  @@_tags_by_name = hash_tags_by_name()
  
end