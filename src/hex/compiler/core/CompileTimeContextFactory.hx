package hex.compiler.core;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import hex.collection.ILocator;
import hex.collection.ILocatorListener;
import hex.collection.Locator;
import hex.compiler.factory.DomainListenerFactory;
import hex.compiler.factory.StateTransitionFactory;
import hex.compiletime.basic.CompileTimeCoreFactory;
import hex.compiletime.basic.IContextFactory;
import hex.compiletime.basic.vo.FactoryVOTypeDef;
import hex.compiletime.factory.FactoryUtil;
import hex.compiletime.factory.PropertyFactory;
import hex.control.trigger.ICommandTrigger;
import hex.core.ContextTypeList;
import hex.core.HashCodeFactory;
import hex.core.IAnnotationParsable;
import hex.core.IApplicationContext;
import hex.core.IBuilder;
import hex.core.ICoreFactory;
import hex.core.SymbolTable;
import hex.di.IInjectorContainer;
import hex.event.IDispatcher;
import hex.factory.BuildRequest;
import hex.ioc.vo.DomainListenerVO;
import hex.ioc.vo.StateTransitionVO;
import hex.ioc.vo.TransitionVO;
import hex.metadata.IAnnotationProvider;
import hex.module.IContextModule;
import hex.util.MacroUtil;
import hex.vo.ConstructorVO;
import hex.vo.MethodCallVO;
import hex.vo.PropertyVO;

using Lambda;

/**
 * ...
 * @author Francis Bourre
 */
class CompileTimeContextFactory 
	implements IBuilder<BuildRequest>
	implements IContextFactory 
	implements ILocatorListener<String, Dynamic>
{
	static var _annotationParsableInterface = MacroUtil.getClassType( Type.getClassName( IAnnotationParsable ) );
	static var _commandTriggerInterface 	= MacroUtil.getClassType( Type.getClassName( ICommandTrigger ) );
	static var _injectorContainerInterface 	= MacroUtil.getClassType( Type.getClassName( IInjectorContainer ) );
	static var _moduleInterface 			= MacroUtil.getClassType( Type.getClassName( IContextModule ) );
	static var _dependencyInterface 		= MacroUtil.getClassType( Type.getClassName( hex.di.mapping.IDependencyOwner ) );
	
	var _isInitialized				: Bool;
	var _expressions 				: Array<Expr>;
	var _mappedTypes 				: Array<Expr>;
	var _injectedInto 				: Array<Expr>;
	
	var _annotationProvider			: IAnnotationProvider;
	var _contextDispatcher			: IDispatcher<{}>;
	var _moduleLocator				: Locator<String, String>;
	var _applicationContext 		: IApplicationContext;
	var _factoryMap 				: Map<String, FactoryVOTypeDef->Dynamic>;
	var _coreFactory 				: ICoreFactory;
	var _symbolTable 				: SymbolTable;
	var _constructorVOLocator 		: Locator<String, ConstructorVO>;
	var _propertyVOLocator 			: Locator<String, Array<PropertyVO>>;
	var _methodCallVOLocator 		: Locator<String, MethodCallVO>;
	var _typeLocator 				: Locator<String, String>;
	var _domainListenerVOLocator 	: Locator<String, DomainListenerVO>;
	var _stateTransitionVOLocator 	: Locator<String, StateTransitionVO>;
	
	var _transitions				: Array<TransitionVO>;
	
	public function new( expressions : Array<Expr>, assemblerID : UInt )
	{
		this._expressions = expressions;
		this._isInitialized = false;
	}
	
	public function init( applicationContext : IApplicationContext ) : Void
	{
		if ( !this._isInitialized )
		{
			this._isInitialized = true;
			
			this._applicationContext 				= applicationContext;
			this._coreFactory 						= cast ( applicationContext.getCoreFactory(), CompileTimeCoreFactory );
			this._coreFactory.register( this._applicationContext.getName(), this._applicationContext );
		
			this._symbolTable 						= new SymbolTable();
			this._constructorVOLocator 				= new Locator();
			this._propertyVOLocator 				= new Locator();
			this._methodCallVOLocator 				= new Locator();
			this._typeLocator 						= new Locator();
			this._domainListenerVOLocator 			= new Locator();
			this._stateTransitionVOLocator 			= new Locator();
			this._moduleLocator 					= new Locator();
			this._mappedTypes 						= [];
			this._injectedInto 						= [];
			
			DomainListenerFactory.domainLocator = new Map();
			this._factoryMap = hex.compiler.core.CompileTimeSettings.factoryMap;
			this._coreFactory.addListener( this );
		}
	}

	public function build( request : BuildRequest ) : Void
	{
		switch( request )
		{
			case PREPROCESS( vo ): this.preprocess( vo );
			case OBJECT( vo ): this.registerConstructorVO( vo );
			case PROPERTY( vo ): this.registerPropertyVO( vo );
			case METHOD_CALL( vo ): this.registerMethodCallVO( vo );
			case DOMAIN_LISTENER( vo ): this.registerDomainListenerVO( vo );
			case STATE_TRANSITION( vo ): this.registerStateTransitionVO( vo );
		}
	}
	
	public function finalize() : Void
	{
		this.buildAllStateTransitions();
		this.dispatchAssemblingStart();
		this.buildAllObjects();
		this.buildAllProperties();
		this.assignAllDomainListeners();
		this.callAllMethods();
		this.callModuleInitialisation();
		this.dispatchAssemblingEnd();
	}
	
	public function dispose() : Void
	{
		this._coreFactory.removeListener( this );
		this._coreFactory.clear();
		this._constructorVOLocator.release();
		this._propertyVOLocator.release();
		this._methodCallVOLocator.release();
		this._typeLocator.release();
		this._domainListenerVOLocator.release();
		this._stateTransitionVOLocator.release();
		this._moduleLocator.release();
		this._factoryMap = hex.compiler.core.CompileTimeSettings.factoryMap;
		this._symbolTable.clear();
		this._mappedTypes = [];
		this._injectedInto = [];
		
		DomainListenerFactory.domainLocator = null;
	}
	
	public function getCoreFactory() : ICoreFactory
	{
		return this._coreFactory;
	}
	
	public function getTypeLocator() : ILocator<String, String>
	{
		return this._typeLocator;
	}
	
	public function dispatchAssemblingStart() : Void
	{
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.ASSEMBLING_START" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function dispatchAssemblingEnd() : Void
	{
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.ASSEMBLING_END" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function registerStateTransitionVO( stateTransitionVO : StateTransitionVO ) : Void
	{
		this._stateTransitionVOLocator.register( stateTransitionVO.ID, stateTransitionVO );
	}
	
	public function buildStateTransition( key : String ) : Array<TransitionVO>
	{
		var transitions : Array<TransitionVO> = null;

		if ( this._stateTransitionVOLocator.isRegisteredWithKey( key ) )
		{
			var stateTransitionVO = this._stateTransitionVOLocator.locate( key );
			stateTransitionVO.expressions = this._expressions;
			transitions = StateTransitionFactory.build( stateTransitionVO, this );
			this._stateTransitionVOLocator.unregister( key );
		}

		return transitions;
	}
	
	public function buildAllStateTransitions() : Void
	{
		this._transitions = [];
		var keys : Array<String> = this._stateTransitionVOLocator.keys();
		
		for ( key in keys )
		{
			this._transitions = this._transitions.concat( this.buildStateTransition( key ) );
		}

		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.STATE_TRANSITIONS_BUILT" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	//
	public function preprocess( vo : hex.vo.PreProcessVO ) : Void
	{
		//We have only 1 preprocessor for now
		var e = hex.compiletime.factory.RuntimeParameterProcessor.process( this, vo );
		if ( e != null ) this._expressions.push( e );
	}
	
	public function registerPropertyVO( propertyVO : PropertyVO ) : Void
	{
		var id = propertyVO.ownerID;
		
		if ( this._propertyVOLocator.isRegisteredWithKey( id ) )
		{
			this._propertyVOLocator.locate( id ).push( propertyVO );
		}
		else
		{
			this._propertyVOLocator.register( id, [ propertyVO ] );
		}
	}
	
	//listen to CoreFactory
	public function onRegister( key : String, instance : Dynamic ) : Void
	{
		this.buildProperty( key );
	}

    public function onUnregister( key : String ) : Void  { }
	
	//
	public function registerConstructorVO( constructorVO : ConstructorVO ) : Void
	{
		this._constructorVOLocator.register( constructorVO.ID, constructorVO );
	}
	
	public function buildObject( id : String ) : Void
	{
		if ( this._constructorVOLocator.isRegisteredWithKey( id ) )
		{
			this.buildVO( this._constructorVOLocator.locate( id ), id );
			this._constructorVOLocator.unregister( id );
		}
	}
	
	public function buildAllObjects() : Void
	{
		this._constructorVOLocator.keys().map( this.buildObject );
		
		//Append to final expressions stack
		this._mappedTypes.map( this._expressions.push );
		this._injectedInto.map( this._expressions.push );
		
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.OBJECTS_BUILT" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
		
		StateTransitionFactory.flush( this._expressions, this._transitions );
	}
	
	public function buildProperty( key : String ) : Void
	{
		if ( this._propertyVOLocator.isRegisteredWithKey( key ) )
		{
			this._propertyVOLocator.locate( key )
				.map( function( property ) this._expressions.push( macro @:mergeBlock ${ PropertyFactory.build( this, property ) } ) );
			this._propertyVOLocator.unregister( key );
		}
	}
	
	public function buildAllProperties() : Void
	{
		this._propertyVOLocator.keys().map( this.buildProperty );
	}
	
	public function registerDomainListenerVO( domainListenerVO : DomainListenerVO ) : Void
	{
		this._domainListenerVOLocator.register( "" + HashCodeFactory.getKey( domainListenerVO ), domainListenerVO );
	}
		
	public function assignAllDomainListeners() : Void
	{
		var listeners : Array<String> = this._domainListenerVOLocator.keys();
		for ( key in listeners )
		{
			this.assignDomainListener( key );
		}
		
		this._domainListenerVOLocator.clear();
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.DOMAIN_LISTENERS_ASSIGNED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}

	public function assignDomainListener( id : String ) : Bool
	{
		return DomainListenerFactory.build( this._expressions, this._getFactoryVO( null ), this._domainListenerVOLocator.locate( id ), this._moduleLocator );
	}
	
	public function registerMethodCallVO( methodCallVO : MethodCallVO ) : Void
	{
		var index : Int = this._methodCallVOLocator.keys().length +1;
		this._methodCallVOLocator.register( "" + index, methodCallVO );
	}
	
	public function callMethod( id : String ) : Void
	{
		var method 			= this._methodCallVOLocator.locate( id );
		var methodName 		= method.name;
		var cons 			= new ConstructorVO( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + methodName ] );
		var func : Dynamic 	= this.buildVO( cons );
		var arguments 		= method.arguments;

		var idArgs = method.ownerID + "_" + method.name + "Args";
		var varIDArgs = macro $i { idArgs };
		var args = [];

		var l : Int = arguments.length;
		for ( i in 0...l )
		{
			args.push( this.buildVO( arguments[ i ] ) );
		}
		
		var varOwner = macro $p{ method.ownerID.split('.') };
		this._expressions.push( macro @:mergeBlock { $varOwner.$methodName( $a{ args } ); } );
	}

	public function callAllMethods() : Void
	{
		var keyList : Array<String> = this._methodCallVOLocator.keys();
		for ( key in keyList )
		{
			this.callMethod(  key );
		}
		
		this._methodCallVOLocator.clear();

		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.METHODS_CALLED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}
	
	public function callModuleInitialisation() : Void
	{
		var domains = this._moduleLocator.values();
		for ( moduleName in domains )
		{
			this._expressions.push( macro @:mergeBlock { $i{moduleName}.initialize(applicationContext); } );
		}
		
		this._moduleLocator.clear();
		
		var messageType = MacroUtil.getStaticVariable( "hex.core.ApplicationAssemblerMessage.MODULES_INITIALIZED" );
		this._expressions.push( macro @:mergeBlock { applicationContext.dispatch( $messageType ); } );
	}

	public function getApplicationContext() : IApplicationContext
	{
		return this._applicationContext;
	}

	public function buildVO( constructorVO : ConstructorVO, ?id : String ) : Dynamic
	{
		constructorVO.shouldAssign 	= id != null;
		
		var type = constructorVO.className;
		var buildMethod : FactoryVOTypeDef->Dynamic = null;
		
		if ( this._factoryMap.exists( type ) )
		{
			buildMethod = this._factoryMap.get( type );
		}
		else if( constructorVO.ref != null )
		{
			buildMethod = hex.compiletime.factory.ReferenceFactory.build;
		}
		else
		{
			buildMethod = hex.compiler.factory.ClassInstanceFactory.build;
		}
		
		var result = buildMethod( this._getFactoryVO( constructorVO ) );
		
		this._checkDependencies( constructorVO );

		if ( id != null )
		{
			this._typeLocator.register( id, constructorVO.type );
			
			this._tryToRegisterModule( constructorVO );
			this._parseInjectInto( constructorVO );
			this._parseMapTypes( constructorVO );
			
			var finalResult = result;
			finalResult = this._parseAnnotation( constructorVO, finalResult );
			finalResult = this._parseCommandTrigger( constructorVO, finalResult );

			this._expressions.push( macro @:mergeBlock { $finalResult;  coreFactory.register( $v { id }, $i { id } ); } );
			this._coreFactory.register( id, result );
		}

		return result;
	}
	
	function _getMappingDefinition( e )
	{
		switch( e.expr )
		{
			case EObjectDecl( fields ):

				return fields.fold ( 
					function (f, o) 
					{
						switch( f.field )
						{
							case 'fromType': Reflect.setField( o, f.field, haxe.macro.ExprTools.getValue( f.expr ) );
							case 'withName': Reflect.setField( o, f.field, haxe.macro.ExprTools.getValue( f.expr ) );
							case _:
						}
						return o;
					}, {} );

			case _:
		}
		
		return null;
	}
	
	function _getMappingDefinitions( e : Expr )
	{
		var a = [];
		switch( e.expr )
		{
			case EVars( vars ) :
				if ( vars[ 0 ].type != null )
				{
					if ( haxe.macro.ComplexTypeTools.toString( vars[ 0 ].type ) == 'Array<hex.di.mapping.MappingDefinition>' )
					{
						switch( vars[ 0 ].expr.expr )
						{
							case EArrayDecl( values ):
								for ( value in values ) 
								{
									switch( value.expr )
									{
										case EObjectDecl( fields ):
											var mapping = _getMappingDefinition( value );
											if ( mapping != null ) a.push( mapping );
											
										case EConst(CIdent(ident)):
											a = a.concat( _getMappingDefinitions( this._coreFactory.locate( ident ) ) );
											
										case wtf:
											trace( 'wtf', wtf );
									}
								}

							case _:
						}
						
					}
					else if ( haxe.macro.ComplexTypeTools.toString( vars[ 0 ].type ) == 'hex.di.mapping.MappingDefinition' )
					{
						var mapping = _getMappingDefinition( vars[ 0 ].expr );
						if ( mapping != null ) a.push( mapping );
					}
				}
				
			case _:
		}
		
		return a;
	}
	
	function _checkDependencies( constructorVO : ConstructorVO ) : Void
	{
		if ( MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _dependencyInterface ) )
		{
			var mappings = constructorVO.arguments.filter(
				function ( arg ) return arg.ref != null )
			.map( function ( arg ) return this._coreFactory.locate( arg.ref ) )
			.flatMap( _getMappingDefinitions );
			
			if ( !hex.di.mapping.MappingChecker.matchForClassName( constructorVO.className, cast mappings ) )
			{
				var missingMappings = hex.di.mapping.MappingChecker.getMissingMapping( constructorVO.className, cast mappings );
				Context.fatalError( "Missing mappings:" + missingMappings, constructorVO.filePosition );
			}
		}
	}
	
	function _tryToRegisterModule( constructorVO : ConstructorVO ) : Void
	{
		if ( MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _moduleInterface ) )
		{
			this._moduleLocator.register( constructorVO.ID, constructorVO.ID );
		}
	}
	
	function _parseInjectInto( constructorVO : ConstructorVO ) : Void
	{
		if ( constructorVO.injectInto && MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _injectorContainerInterface ) )
		{
			//TODO throws an error if interface is not implemented
			this._injectedInto.push( 
				macro 	@:pos( constructorVO.filePosition )
						@:mergeBlock
						{ 
							__applicationContextInjector.injectInto( $i{ constructorVO.ID } ); 
						}
			);
		}
	}

	function _parseAnnotation( constructorVO : ConstructorVO, result : Expr ) : Expr
	{
		if ( MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _annotationParsableInterface ) )
		{
			result = macro 	@:pos( constructorVO.filePosition ) 
							@:mergeBlock 
							{ 
								$result; 
								__annotationProvider.parse( $i{ constructorVO.ID } ); 
							};
		}
		
		return result;
	}
	
	function _parseCommandTrigger( constructorVO : ConstructorVO, result : Expr ) : Expr
	{
		if ( !constructorVO.injectInto && MacroUtil.implementsInterface( this._getClassType( constructorVO.className ), _commandTriggerInterface ) )
		{
			result = macro 	@:pos( constructorVO.filePosition ) 
							@:mergeBlock
							{ 
								$result; 
								__applicationContextInjector.injectInto( $i{ constructorVO.ID } ); 
							};
		}
		
		return result;
	}
	
	function _parseMapTypes( constructorVO : ConstructorVO ) : Void
	{
		if ( constructorVO.mapTypes != null )
		{
			var mapTypes = constructorVO.mapTypes;
			for ( mapType in mapTypes )
			{
				//Check if class exists
				FactoryUtil.checkTypeParamsExist( mapType, constructorVO.filePosition );
				
				//Remove whitespaces
				mapType = mapType.split( ' ' ).join( '' );
				
				//Map it
				this._mappedTypes.push( 
					macro 	@:pos( constructorVO.filePosition ) 
							@:mergeBlock 
							{
								__applicationContextInjector.mapClassNameToValue
								( $v{ mapType }, $i{ constructorVO.ID }, $v{ constructorVO.ID } 
								);
							}
				);
			}
		}
	}
	
	function _getFactoryVO( constructorVO : ConstructorVO = null ) : FactoryVOTypeDef
	{
		return { constructorVO : constructorVO, contextFactory : this };
	}
	
	//helper
	function _getClassType( className : String ) : ClassType
	{
		try
		{
			return switch Context.getType( className ) 
			{
				case TInst( t, _ ): t.get();
				default: null;
			}
		}
		catch ( e : Dynamic )
		{
			return null;
		}
	}
}
#end