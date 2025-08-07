import '../models/meal_model.dart';
import '../models/user_model.dart';

class MealRecommendationService {
  // Danh sách món ăn Việt Nam cho giảm cân
  static final List<MealModel> _vietnameseMeals = [
    // Bữa sáng
    MealModel(
      id: 'pho_ga',
      name: 'Phở gà không dầu mỡ',
      nameEn: 'Fat-free Chicken Pho',
      category: MealCategory.breakfast,
      calories: 280,
      protein: 25,
      carbs: 35,
      fat: 5,
      fiber: 3,
      preparationTime: 30,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Thịt gà luộc',
        'Bánh phở',
        'Hành lá',
        'Ngò gai',
        'Nước dùng gà trong'
      ],
      instructions: [
        'Luộc gà bỏ da và mỡ',
        'Nấu nước dùng trong',
        'Trần bánh phở',
        'Bày món và thưởng thức'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['low-fat', 'high-protein', 'vietnamese'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'chao_yen_mach',
      name: 'Cháo yến mạch chuối',
      nameEn: 'Banana Oatmeal Porridge',
      category: MealCategory.breakfast,
      calories: 320,
      protein: 12,
      carbs: 45,
      fat: 8,
      fiber: 6,
      preparationTime: 15,
      difficulty: MealDifficulty.easy,
      ingredients: [
        'Yến mạch',
        'Chuối chín',
        'Sữa tươi không đường',
        'Hạt chia'
      ],
      instructions: [
        'Nấu yến mạch với sữa',
        'Thêm chuối nghiền',
        'Rắc hạt chia lên trên'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['high-fiber', 'low-sugar', 'breakfast'],
      useNetworkImage: true,
    ),

    // Thêm món ăn sáng mới
    MealModel(
      id: 'banh_mi_nguyen_cam',
      name: 'Bánh mì nguyên cám chà bông',
      nameEn: 'Whole Wheat Bread with Pork Floss',
      category: MealCategory.breakfast,
      calories: 350,
      protein: 18,
      carbs: 40,
      fat: 12,
      fiber: 5,
      preparationTime: 10,
      difficulty: MealDifficulty.easy,
      ingredients: [
        'Bánh mì nguyên cám',
        'Chà bông',
        'Bơ thực vật',
        'Dưa chuột'
      ],
      instructions: [
        'Nướng bánh mì vàng',
        'Phết bơ mỏng',
        'Rắc chà bông',
        'Thêm dưa chuột thái lát'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['whole-grain', 'protein', 'quick'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'xoi_gac_chay',
      name: 'Xôi gấc chay',
      nameEn: 'Vegetarian Red Sticky Rice',
      category: MealCategory.breakfast,
      calories: 290,
      protein: 8,
      carbs: 55,
      fat: 4,
      fiber: 3,
      preparationTime: 45,
      difficulty: MealDifficulty.medium,
      ingredients: ['Gạo nếp', 'Quả gấc', 'Dừa nạo', 'Muối'],
      instructions: [
        'Ngâm gạo nếp qua đêm',
        'Nấu với nước gấc',
        'Rắc dừa nạo lên trên'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['traditional', 'antioxidant', 'natural'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'chao_ca_hoi',
      name: 'Cháo cá hồi rau củ',
      nameEn: 'Salmon Vegetable Porridge',
      category: MealCategory.breakfast,
      calories: 380,
      protein: 22,
      carbs: 35,
      fat: 15,
      fiber: 4,
      preparationTime: 25,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Cá hồi tươi',
        'Gạo tẻ',
        'Cà rốt',
        'Bông cải xanh',
        'Hành lá'
      ],
      instructions: [
        'Nấu cháo gạo',
        'Thêm cá hồi và rau củ',
        'Nêm nếm vừa ăn',
        'Rắc hành lá'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['omega-3', 'nutritious', 'easy-digest'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'banh_cuon_chay',
      name: 'Bánh cuốn chay nấm',
      nameEn: 'Vegetarian Steamed Rice Rolls',
      category: MealCategory.breakfast,
      calories: 260,
      protein: 10,
      carbs: 45,
      fat: 6,
      fiber: 3,
      preparationTime: 30,
      difficulty: MealDifficulty.hard,
      ingredients: [
        'Bánh cuốn',
        'Nấm hương',
        'Đậu hũ',
        'Hành tây',
        'Nước mắm chay'
      ],
      instructions: [
        'Xào nhân nấm đậu hũ',
        'Cuốn bánh với nhân',
        'Chấm nước mắm chay'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['low-calorie', 'traditional', 'light'],
      useNetworkImage: true,
    ),

    // Bữa trưa
    MealModel(
      id: 'com_gao_lut_ca_thu',
      name: 'Cơm gạo lứt + Cá thu nướng',
      nameEn: 'Brown Rice + Grilled Mackerel',
      category: MealCategory.lunch,
      calories: 450,
      protein: 30,
      carbs: 45,
      fat: 15,
      fiber: 4,
      preparationTime: 45,
      difficulty: MealDifficulty.medium,
      ingredients: ['Gạo lứt', 'Cá thu tươi', 'Rau củ', 'Gia vị'],
      instructions: [
        'Nấu cơm gạo lứt',
        'Nướng cá thu với ít dầu',
        'Luộc rau củ'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['omega-3', 'whole-grain', 'balanced'],
    ),

    MealModel(
      id: 'goi_cuon_tom_thit',
      name: 'Gỏi cuốn tôm thịt',
      nameEn: 'Shrimp Pork Spring Rolls',
      category: MealCategory.lunch,
      calories: 380,
      protein: 25,
      carbs: 35,
      fat: 10,
      fiber: 5,
      preparationTime: 20,
      difficulty: MealDifficulty.easy,
      ingredients: [
        'Bánh tráng',
        'Tôm luộc',
        'Thịt luộc',
        'Rau sống',
        'Bún tươi'
      ],
      instructions: [
        'Luộc tôm và thịt',
        'Chuẩn bị rau sống',
        'Cuốn bánh tráng',
        'Chấm nước mắm pha'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['fresh', 'low-calorie', 'vietnamese'],
    ),

    // Thêm món ăn trưa mới
    MealModel(
      id: 'bun_bo_hue_chay',
      name: 'Bún bò Huế chay',
      nameEn: 'Vegetarian Hue Beef Noodle Soup',
      category: MealCategory.lunch,
      calories: 420,
      protein: 18,
      carbs: 55,
      fat: 12,
      fiber: 6,
      preparationTime: 40,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Bún tươi',
        'Đậu hũ',
        'Nấm hương',
        'Rau sống',
        'Nước dùng chay'
      ],
      instructions: [
        'Nấu nước dùng chay thơm',
        'Trần bún',
        'Xào đậu hũ và nấm',
        'Bày món với rau sống'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['spicy', 'traditional', 'filling'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'com_tam_suon_nuong',
      name: 'Cơm tấm sườn nướng',
      nameEn: 'Broken Rice with Grilled Pork Ribs',
      category: MealCategory.lunch,
      calories: 520,
      protein: 28,
      carbs: 50,
      fat: 20,
      fiber: 3,
      preparationTime: 35,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Cơm tấm',
        'Sườn heo',
        'Đồ chua',
        'Nước mắm pha',
        'Rau sống'
      ],
      instructions: [
        'Ướp sườn với gia vị',
        'Nướng sườn vàng đều',
        'Nấu cơm tấm',
        'Bày món với đồ chua'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['grilled', 'traditional', 'protein-rich'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'mi_quang_ga',
      name: 'Mì Quảng gà',
      nameEn: 'Quang Style Chicken Noodles',
      category: MealCategory.lunch,
      calories: 460,
      protein: 26,
      carbs: 48,
      fat: 16,
      fiber: 4,
      preparationTime: 45,
      difficulty: MealDifficulty.medium,
      ingredients: ['Mì Quảng', 'Thịt gà', 'Tôm', 'Trứng cút', 'Rau sống'],
      instructions: [
        'Nấu nước dùng gà',
        'Luộc mì Quảng',
        'Xào gà và tôm',
        'Bày món với rau sống'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['regional', 'nutritious', 'colorful'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'canh_chua_ca_basa',
      name: 'Canh chua cá basa',
      nameEn: 'Sour Fish Soup',
      category: MealCategory.lunch,
      calories: 280,
      protein: 22,
      carbs: 15,
      fat: 8,
      fiber: 4,
      preparationTime: 25,
      difficulty: MealDifficulty.easy,
      ingredients: ['Cá basa', 'Cà chua', 'Dứa', 'Đậu bắp', 'Ngò gai'],
      instructions: [
        'Nấu nước dùng chua',
        'Thêm cá và rau củ',
        'Nêm nếm vừa ăn',
        'Rắc ngò gai'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['sour', 'light', 'vitamin-c'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'bun_cha_ha_noi',
      name: 'Bún chả Hà Nội',
      nameEn: 'Hanoi Grilled Pork with Noodles',
      category: MealCategory.lunch,
      calories: 480,
      protein: 24,
      carbs: 45,
      fat: 18,
      fiber: 5,
      preparationTime: 30,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Bún tươi',
        'Thịt nướng',
        'Chả cá',
        'Rau sống',
        'Nước mắm pha'
      ],
      instructions: [
        'Nướng thịt thơm',
        'Chiên chả cá',
        'Trần bún',
        'Chấm với nước mắm pha'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['grilled', 'hanoi-style', 'balanced'],
      useNetworkImage: true,
    ),

    // Bữa phụ
    MealModel(
      id: 'che_dau_xanh',
      name: 'Chè đậu xanh không đường',
      nameEn: 'Sugar-free Mung Bean Dessert',
      category: MealCategory.snack,
      calories: 180,
      protein: 8,
      carbs: 30,
      fat: 3,
      fiber: 4,
      preparationTime: 30,
      difficulty: MealDifficulty.easy,
      ingredients: ['Đậu xanh', 'Nước cốt dừa ít béo', 'Lá dứa'],
      instructions: [
        'Nấu đậu xanh mềm',
        'Thêm nước cốt dừa',
        'Không thêm đường'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['no-sugar', 'traditional', 'protein'],
    ),

    MealModel(
      id: 'sinh_to_bo',
      name: 'Sinh tố bơ sữa chua',
      nameEn: 'Avocado Yogurt Smoothie',
      category: MealCategory.snack,
      calories: 220,
      protein: 6,
      carbs: 25,
      fat: 12,
      fiber: 8,
      preparationTime: 10,
      difficulty: MealDifficulty.easy,
      ingredients: ['Bơ chín', 'Sữa chua không đường', 'Mật ong', 'Đá'],
      instructions: [
        'Xay bơ với sữa chua',
        'Thêm mật ong',
        'Cho đá và xay nhuyễn'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['creamy', 'healthy-fat', 'probiotic'],
      useNetworkImage: true,
    ),

    // Thêm món ăn vặt mới
    MealModel(
      id: 'banh_flan_dau_xanh',
      name: 'Bánh flan đậu xanh',
      nameEn: 'Mung Bean Flan',
      category: MealCategory.snack,
      calories: 160,
      protein: 7,
      carbs: 28,
      fat: 4,
      fiber: 3,
      preparationTime: 60,
      difficulty: MealDifficulty.medium,
      ingredients: ['Đậu xanh', 'Trứng gà', 'Sữa tươi ít béo', 'Đường ít'],
      instructions: [
        'Nấu đậu xanh nhuyễn',
        'Trộn với trứng và sữa',
        'Hấp trong 30 phút'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['protein-rich', 'traditional', 'low-sugar'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'che_ba_mau_chay',
      name: 'Chè ba màu chay',
      nameEn: 'Vegetarian Three-Color Dessert',
      category: MealCategory.snack,
      calories: 200,
      protein: 5,
      carbs: 40,
      fat: 5,
      fiber: 4,
      preparationTime: 45,
      difficulty: MealDifficulty.medium,
      ingredients: ['Đậu xanh', 'Đậu đỏ', 'Thạch lá dứa', 'Nước cốt dừa'],
      instructions: [
        'Nấu các loại đậu',
        'Làm thạch lá dứa',
        'Xếp lớp và thêm nước cốt dừa'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['colorful', 'traditional', 'fiber-rich'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'banh_khoai_lang_nuong',
      name: 'Bánh khoai lang nướng',
      nameEn: 'Roasted Sweet Potato',
      category: MealCategory.snack,
      calories: 140,
      protein: 3,
      carbs: 32,
      fat: 1,
      fiber: 5,
      preparationTime: 40,
      difficulty: MealDifficulty.easy,
      ingredients: ['Khoai lang', 'Muối', 'Lá chuối'],
      instructions: [
        'Rửa sạch khoai lang',
        'Gói lá chuối',
        'Nướng trong 30 phút'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['natural', 'vitamin-a', 'simple'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'tra_atiso_mat_ong',
      name: 'Trà atiso mật ong',
      nameEn: 'Artichoke Tea with Honey',
      category: MealCategory.snack,
      calories: 80,
      protein: 1,
      carbs: 20,
      fat: 0,
      fiber: 2,
      preparationTime: 15,
      difficulty: MealDifficulty.easy,
      ingredients: ['Atiso khô', 'Mật ong', 'Nước sôi'],
      instructions: ['Pha atiso với nước sôi', 'Để nguội', 'Thêm mật ong'],
      isHealthy: true,
      isVegetarian: true,
      tags: ['detox', 'antioxidant', 'low-calorie'],
      useNetworkImage: true,
    ),

    // Bữa tối
    MealModel(
      id: 'canh_chua_ca_basa',
      name: 'Canh chua cá basa',
      nameEn: 'Basa Fish Sour Soup',
      category: MealCategory.dinner,
      calories: 250,
      protein: 22,
      carbs: 15,
      fat: 8,
      fiber: 3,
      preparationTime: 25,
      difficulty: MealDifficulty.medium,
      ingredients: ['Cá basa', 'Cà chua', 'Dứa', 'Giá đỗ', 'Me'],
      instructions: ['Nấu nước dùng chua', 'Thêm cá basa', 'Cho rau vào cuối'],
      isHealthy: true,
      isVegetarian: false,
      tags: ['low-calorie', 'sour', 'light-dinner'],
    ),

    MealModel(
      id: 'goi_ga_bap_cai',
      name: 'Gỏi gà bắp cải',
      nameEn: 'Chicken Cabbage Salad',
      category: MealCategory.dinner,
      calories: 280,
      protein: 25,
      carbs: 15,
      fat: 12,
      fiber: 6,
      preparationTime: 20,
      difficulty: MealDifficulty.easy,
      ingredients: [
        'Thịt gà luộc',
        'Bắp cải tươi',
        'Cà rốt',
        'Rau thơm',
        'Nước mắm chanh'
      ],
      instructions: [
        'Luộc gà, xé nhỏ',
        'Thái bắp cải mỏng',
        'Trộn với nước mắm chanh'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['fresh', 'low-carb', 'high-protein'],
    ),

    // Thêm món ăn tối mới
    MealModel(
      id: 'sup_mang_cua',
      name: 'Súp măng cua',
      nameEn: 'Crab and Bamboo Shoot Soup',
      category: MealCategory.dinner,
      calories: 220,
      protein: 18,
      carbs: 12,
      fat: 8,
      fiber: 4,
      preparationTime: 30,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Thịt cua',
        'Măng tươi',
        'Trứng gà',
        'Hành lá',
        'Nước dùng'
      ],
      instructions: [
        'Nấu nước dùng trong',
        'Thêm măng và cua',
        'Đánh trứng vào',
        'Rắc hành lá'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['light', 'protein-rich', 'traditional'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'ca_kho_to',
      name: 'Cá kho tộ',
      nameEn: 'Braised Fish in Clay Pot',
      category: MealCategory.dinner,
      calories: 320,
      protein: 28,
      carbs: 8,
      fat: 18,
      fiber: 2,
      preparationTime: 40,
      difficulty: MealDifficulty.medium,
      ingredients: ['Cá basa', 'Nước mắm', 'Đường thốt nốt', 'Ớt', 'Hành tây'],
      instructions: [
        'Ướp cá với gia vị',
        'Kho với nước mắm',
        'Nấu đến cá thấm gia vị'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['traditional', 'flavorful', 'omega-3'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'dau_hu_sot_ca_chua',
      name: 'Đậu hũ sốt cà chua',
      nameEn: 'Tofu in Tomato Sauce',
      category: MealCategory.dinner,
      calories: 240,
      protein: 15,
      carbs: 18,
      fat: 12,
      fiber: 5,
      preparationTime: 25,
      difficulty: MealDifficulty.easy,
      ingredients: ['Đậu hũ', 'Cà chua', 'Hành tây', 'Tỏi', 'Rau thơm'],
      instructions: [
        'Chiên đậu hũ vàng',
        'Xào cà chua',
        'Nấu cùng đậu hũ',
        'Rắc rau thơm'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['vegetarian', 'protein', 'lycopene'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'thit_kho_tau',
      name: 'Thịt kho tàu',
      nameEn: 'Braised Pork Belly',
      category: MealCategory.dinner,
      calories: 380,
      protein: 22,
      carbs: 15,
      fat: 25,
      fiber: 2,
      preparationTime: 60,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Thịt ba chỉ',
        'Trứng',
        'Nước mắm',
        'Đường thốt nốt',
        'Nước dừa'
      ],
      instructions: [
        'Luộc thịt sơ qua',
        'Kho với nước dừa',
        'Thêm trứng luộc',
        'Nấu đến thịt mềm'
      ],
      isHealthy: false,
      isVegetarian: false,
      tags: ['traditional', 'comfort-food', 'rich'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'rau_muong_xao_toi',
      name: 'Rau muống xào tỏi',
      nameEn: 'Stir-fried Water Spinach with Garlic',
      category: MealCategory.dinner,
      calories: 120,
      protein: 4,
      carbs: 8,
      fat: 8,
      fiber: 6,
      preparationTime: 10,
      difficulty: MealDifficulty.easy,
      ingredients: ['Rau muống', 'Tỏi', 'Dầu ăn', 'Nước mắm', 'Ớt'],
      instructions: [
        'Nhặt rau muống sạch',
        'Phi tỏi thơm',
        'Xào rau nhanh tay',
        'Nêm nếm vừa ăn'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['vegetarian', 'quick', 'iron-rich'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'tom_rang_me',
      name: 'Tôm rang me',
      nameEn: 'Tamarind Glazed Shrimp',
      category: MealCategory.dinner,
      calories: 290,
      protein: 24,
      carbs: 20,
      fat: 12,
      fiber: 2,
      preparationTime: 20,
      difficulty: MealDifficulty.medium,
      ingredients: ['Tôm sú', 'Me chua', 'Đường', 'Nước mắm', 'Ớt'],
      instructions: [
        'Sơ chế tôm sạch',
        'Pha nước sốt me',
        'Rang tôm với sốt',
        'Nấu đến tôm chín đều'
      ],
      isHealthy: true,
      isVegetarian: false,
      tags: ['seafood', 'sweet-sour', 'protein-rich'],
      useNetworkImage: true,
    ),

    // Tráng miệng
    MealModel(
      id: 'che_thap_cam',
      name: 'Chè thập cẩm',
      nameEn: 'Mixed Sweet Soup',
      category: MealCategory.dessert,
      calories: 250,
      protein: 6,
      carbs: 50,
      fat: 5,
      fiber: 4,
      preparationTime: 45,
      difficulty: MealDifficulty.medium,
      ingredients: [
        'Đậu xanh',
        'Đậu đỏ',
        'Thạch rau câu',
        'Nước cốt dừa',
        'Đường phèn'
      ],
      instructions: [
        'Nấu các loại đậu riêng',
        'Làm thạch rau câu',
        'Pha nước cốt dừa',
        'Xếp lớp và thưởng thức'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['traditional', 'colorful', 'sweet'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'banh_flan_caramen',
      name: 'Bánh flan caramen',
      nameEn: 'Caramel Flan',
      category: MealCategory.dessert,
      calories: 180,
      protein: 8,
      carbs: 25,
      fat: 6,
      fiber: 0,
      preparationTime: 90,
      difficulty: MealDifficulty.hard,
      ingredients: ['Trứng gà', 'Sữa tươi', 'Đường', 'Vani'],
      instructions: [
        'Làm caramen',
        'Trộn hỗn hợp trứng sữa',
        'Hấp trong 45 phút',
        'Để nguội và thưởng thức'
      ],
      isHealthy: false,
      isVegetarian: true,
      tags: ['classic', 'creamy', 'sweet'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'suong_sa_hat_luu',
      name: 'Sương sáo hạt lựu',
      nameEn: 'Grass Jelly with Pomegranate Seeds',
      category: MealCategory.dessert,
      calories: 120,
      protein: 2,
      carbs: 28,
      fat: 1,
      fiber: 3,
      preparationTime: 20,
      difficulty: MealDifficulty.easy,
      ingredients: ['Sương sáo', 'Hạt lựu', 'Nước đường', 'Đá bào'],
      instructions: [
        'Cắt sương sáo thành miếng',
        'Pha nước đường',
        'Cho đá bào',
        'Rắc hạt lựu lên trên'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['refreshing', 'low-calorie', 'cooling'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'banh_chuoi_nuong',
      name: 'Bánh chuối nướng',
      nameEn: 'Grilled Banana Cake',
      category: MealCategory.dessert,
      calories: 200,
      protein: 4,
      carbs: 40,
      fat: 5,
      fiber: 3,
      preparationTime: 30,
      difficulty: MealDifficulty.easy,
      ingredients: ['Chuối chín', 'Bột mì', 'Trứng', 'Dừa nạo', 'Đường ít'],
      instructions: [
        'Nghiền chuối',
        'Trộn với bột và trứng',
        'Nướng vàng đều',
        'Rắc dừa nạo'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['natural-sweet', 'potassium', 'homemade'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'kem_xoi_dua',
      name: 'Kem xôi dừa',
      nameEn: 'Coconut Sticky Rice Ice Cream',
      category: MealCategory.dessert,
      calories: 220,
      protein: 3,
      carbs: 35,
      fat: 8,
      fiber: 2,
      preparationTime: 60,
      difficulty: MealDifficulty.medium,
      ingredients: ['Xôi nếp', 'Nước cốt dừa', 'Đường', 'Muối', 'Đá'],
      instructions: [
        'Nấu xôi nếp',
        'Trộn với nước cốt dừa',
        'Làm lạnh',
        'Tạo hình kem'
      ],
      isHealthy: false,
      isVegetarian: true,
      tags: ['traditional', 'creamy', 'coconut'],
      useNetworkImage: true,
    ),

    MealModel(
      id: 'tau_hu_nuoc_duong',
      name: 'Tàu hũ nước đường',
      nameEn: 'Silken Tofu in Syrup',
      category: MealCategory.dessert,
      calories: 150,
      protein: 8,
      carbs: 20,
      fat: 4,
      fiber: 1,
      preparationTime: 25,
      difficulty: MealDifficulty.easy,
      ingredients: ['Tàu hũ non', 'Đường phèn', 'Nước', 'Gừng'],
      instructions: [
        'Nấu nước đường phèn',
        'Thêm gừng',
        'Cho tàu hũ vào',
        'Ăn nóng hoặc lạnh'
      ],
      isHealthy: true,
      isVegetarian: true,
      tags: ['protein', 'light', 'traditional'],
      useNetworkImage: true,
    ),
  ];

  // Gợi ý món ăn dựa trên BMI và mục tiêu
  static List<MealModel> getRecommendations({
    required UserModel user,
    required MealCategory category,
    int limit = 5,
  }) {
    List<MealModel> recommendations = [];

    // Lọc theo loại bữa ăn
    var mealsForCategory =
        _vietnameseMeals.where((meal) => meal.category == category).toList();

    // Gợi ý dựa trên BMI
    if (user.bmi < 18.5) {
      // Thiếu cân - cần tăng calo và protein
      mealsForCategory.sort((a, b) => b.calories.compareTo(a.calories));
    } else if (user.bmi >= 25) {
      // Thừa cân - cần giảm calo
      mealsForCategory.sort((a, b) => a.calories.compareTo(b.calories));
      mealsForCategory =
          mealsForCategory.where((meal) => meal.calories < 400).toList();
    } else {
      // Bình thường - cân bằng dinh dưỡng
      mealsForCategory.sort((a, b) => b.protein.compareTo(a.protein));
    }

    recommendations = mealsForCategory.take(limit).toList();
    return recommendations;
  }

  // Tính tổng dinh dưỡng trong ngày
  static NutritionSummary calculateDailyNutrition(List<MealModel> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;

    for (var meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
      totalFiber += meal.fiber;
    }

    return NutritionSummary(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      fiber: totalFiber,
    );
  }

  // Gợi ý thực đơn cả ngày
  static DailyMealPlan getDailyMealPlan(UserModel user) {
    return DailyMealPlan(
      breakfast: getRecommendations(
        user: user,
        category: MealCategory.breakfast,
        limit: 2,
      ),
      lunch: getRecommendations(
        user: user,
        category: MealCategory.lunch,
        limit: 2,
      ),
      snack: getRecommendations(
        user: user,
        category: MealCategory.snack,
        limit: 1,
      ),
      dinner: getRecommendations(
        user: user,
        category: MealCategory.dinner,
        limit: 2,
      ),
    );
  }
}
